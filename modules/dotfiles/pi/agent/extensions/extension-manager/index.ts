// Extension Manager: /ext new|edit|list|save|commit|clean|purge
//
// Editable copies live in ~/.pi/agent/dev-extensions/<name>'/ (the trailing
// quote marks them as editable). Saved extensions are registered in
// modules/dotfiles/pi/pi.nix as loader stubs (see pi.nix) that prefer the
// editable copy when it exists and otherwise import the nix store copy.
// Drafts (editable, not registered yet) are loaded by this extension.
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { access, chmod, copyFile, mkdir, readdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

// Overridable for testing; defaults match this machine.
const CONFIG = {
  nixRepo: process.env.EXT_MANAGER_NIX_REPO ?? join(homedir(), "nix"),
  worktrees: process.env.EXT_MANAGER_WORKTREES ?? join(homedir(), "worktrees", "nix"),
  agentDir: process.env.EXT_MANAGER_AGENT_DIR ?? process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent"),
  baseBranch: process.env.EXT_MANAGER_BASE ?? "main",
};

const EDIT_SUFFIX = "'";
const REL_EXT_DIR = "modules/dotfiles/pi/agent/extensions";
const REL_REGISTRY = "modules/dotfiles/pi/pi.nix";
const BEGIN_MARK = "# BEGIN ext-manager";
const END_MARK = "# END ext-manager";
const NAME_RE = /^[a-z0-9][a-z0-9-]*$/;
const SUBCOMMANDS = ["help", "new", "edit", "adopt", "reload", "list", "save", "commit", "clean", "purge"];
const HELP_TEXT = `/ext subcommands (full docs: agent/extensions/extension-manager/README.md)
  help                  Show this help
  new <name>            Create a draft <name>' from a template, then reload
  edit <name>           Create an editable <name>' copy of a saved extension, then reload
  adopt [name]          Move loose extensions from ~/.pi/agent/extensions into drafts (also runs on start)
  reload                Reload all extensions
  list [changed]        Show extensions and their status (changed: only unsaved/dirty)
  save [name]           Write <name>' to the nix worktree (feat/pi-<name>), register it in pi.nix; not committed
  commit [name] [desc]  Commit worktree changes on feat/pi-<name>
  clean [name]          Safe: remove <name>' and its worktree/branch only if nothing is lost
  purge [name]          Unsafe: delete <name>', worktree and branch even with changes (asks first)
Without a name, save/commit/clean/purge apply to all extensions.`;
const BRANCH_PREFIX = "feat/pi-";
const WORKTREE_PREFIX = "nix-pi-";

const devDir = () => join(CONFIG.agentDir, "dev-extensions");
const settingsPath = () => join(CONFIG.agentDir, "settings.json");
const editablePath = (name: string) => join(devDir(), name + EDIT_SUFFIX);
const looseDir = () => join(CONFIG.agentDir, "extensions"); // auto-loaded by pi, not managed
const branchOf = (name: string) => BRANCH_PREFIX + name;
const worktreePathOf = (name: string) => join(CONFIG.worktrees, WORKTREE_PREFIX + name);

// ---------- process / fs helpers ----------

async function sh(cmd: string, args: string[], cwd?: string): Promise<{ ok: boolean; out: string; err: string }> {
  try {
    const r = await execFileAsync(cmd, args, { cwd, maxBuffer: 32 * 1024 * 1024 });
    return { ok: true, out: r.stdout.trim(), err: r.stderr.trim() };
  } catch (e: any) {
    return { ok: false, out: String(e?.stdout ?? "").trim(), err: String(e?.stderr || e?.message || e).trim() };
  }
}

const git = (args: string[], cwd = CONFIG.nixRepo) => sh("git", args, cwd);

async function exists(p: string): Promise<boolean> {
  try {
    await access(p);
    return true;
  } catch {
    return false;
  }
}

async function listFiles(root: string, rel = ""): Promise<string[]> {
  const out: string[] = [];
  for (const e of await readdir(join(root, rel), { withFileTypes: true })) {
    const r = join(rel, e.name);
    if (e.isDirectory()) out.push(...(await listFiles(root, r)));
    else out.push(r);
  }
  return out.sort();
}

/** Byte-for-byte comparison of two directory trees. */
async function equalTrees(a: string, b: string): Promise<boolean> {
  if (!(await exists(a)) || !(await exists(b))) return false;
  const fa = await listFiles(a);
  const fb = await listFiles(b);
  if (fa.length !== fb.length || fa.some((f, i) => f !== fb[i])) return false;
  for (const f of fa) {
    const [x, y] = [await readFile(join(a, f)), await readFile(join(b, f))];
    if (!x.equals(y)) return false;
  }
  return true;
}

/** Verbatim copy. Store files are read-only, so output modes are normalised to 644/755. */
async function copyTree(src: string, dst: string): Promise<void> {
  await rm(dst, { recursive: true, force: true });
  await mkdir(dst, { recursive: true });
  for (const f of await listFiles(src)) {
    const from = join(src, f);
    const to = join(dst, f);
    await mkdir(dirname(to), { recursive: true });
    const st = await stat(from);
    await copyFile(from, to);
    await chmod(to, st.mode & 0o111 ? 0o755 : 0o644);
  }
}

/** Directory extensions load from index.ts; single files load directly. */
async function entryOf(path: string): Promise<string> {
  return (await stat(path)).isDirectory() ? join(path, "index.ts") : path;
}

// ---------- discovery ----------

interface Registered {
  name: string;
  original: string; // nix store directory the stub imports when no editable copy exists
  stub: string;
}

/** Saved extensions = stubs listed in settings.extensions (generated by pi.nix). */
async function discoverRegistered(): Promise<Map<string, Registered>> {
  const map = new Map<string, Registered>();
  let settings: any;
  try {
    settings = JSON.parse(await readFile(settingsPath(), "utf8"));
  } catch {
    return map;
  }
  for (const entry of Array.isArray(settings?.extensions) ? settings.extensions : []) {
    if (typeof entry !== "string") continue;
    try {
      const src = await readFile(join(entry, "index.ts"), "utf8");
      const name = src.match(/^const NAME = "([^"]+)";/m)?.[1];
      const original = src.match(/^const ORIGINAL = "([^"]+)";/m)?.[1];
      if (name && original) map.set(name, { name, original, stub: entry });
    } catch {
      // not a manager stub (e.g. the extension manager itself)
    }
  }
  return map;
}

async function discoverEditable(): Promise<string[]> {
  if (!(await exists(devDir()))) return [];
  const names: string[] = [];
  for (const e of await readdir(devDir(), { withFileTypes: true })) {
    if (e.isDirectory() && e.name.endsWith(EDIT_SUFFIX)) names.push(e.name.slice(0, -EDIT_SUFFIX.length));
  }
  return names.sort();
}

// ---------- loose extensions ----------

interface Loose {
  name: string;
  path: string;
  isFile: boolean; // single <name>.ts file rather than a <name>/ directory
}

/** Anything pi auto-loads from agent/extensions that the manager does not own yet. Symlinks are skipped. */
async function discoverLoose(): Promise<Loose[]> {
  if (!(await exists(looseDir()))) return [];
  const out: Loose[] = [];
  for (const e of await readdir(looseDir(), { withFileTypes: true })) {
    if (e.name.startsWith(".")) continue;
    const path = join(looseDir(), e.name);
    if (e.isDirectory() && (await exists(join(path, "index.ts")))) {
      out.push({ name: e.name, path, isFile: false });
    } else if (e.isFile() && e.name.endsWith(".ts")) {
      out.push({ name: e.name.slice(0, -".ts".length), path, isFile: true });
    }
  }
  return out.sort((a, b) => a.name.localeCompare(b.name));
}

/** Moves a loose extension to <name>' (a draft the manager loads). The loose copy is removed only after the copy succeeds. */
async function adoptOne(l: Loose): Promise<string> {
  if (!NAME_RE.test(l.name)) return fail(`${l.name}: invalid name (use lowercase letters, digits, dashes); left in place`);
  const ed = editablePath(l.name);
  if (await exists(ed)) return fail(`${l.name}: ${ed} already exists; left loose at ${l.path}`);
  if (l.isFile) {
    await mkdir(ed, { recursive: true });
    await copyFile(l.path, join(ed, "index.ts"));
  } else {
    await copyTree(l.path, ed);
  }
  await rm(l.path, { recursive: true, force: true });
  return ok(`${l.name}: adopted into ${ed}`);
}

interface Worktree {
  path: string;
  branch?: string;
}

async function listWorktrees(): Promise<Worktree[]> {
  const r = await git(["worktree", "list", "--porcelain"]);
  const out: Worktree[] = [];
  let cur: Worktree | undefined;
  for (const line of r.out.split("\n")) {
    if (line.startsWith("worktree ")) {
      cur = { path: line.slice("worktree ".length) };
      out.push(cur);
    } else if (line.startsWith("branch ") && cur) {
      cur.branch = line.slice("branch ".length).replace(/^refs\/heads\//, "");
    }
  }
  return out;
}

const managedWorktree = (wts: Worktree[], name: string) => wts.find((w) => w.branch === branchOf(name));
const branchExists = async (b: string) => (await git(["show-ref", "--verify", "--quiet", `refs/heads/${b}`])).ok;
const isDirty = async (wt: string) => (await git(["status", "--porcelain"], wt)).out.length > 0;
const isMerged = async (b: string) => (await git(["merge-base", "--is-ancestor", b, CONFIG.baseBranch])).ok;

/** Names with a manager-owned worktree (nix-pi-<name> under the worktrees root). */
async function worktreeNames(): Promise<string[]> {
  return (await listWorktrees())
    .map((w) => w.path)
    .filter((p) => p.startsWith(CONFIG.worktrees + "/") && p.split("/").pop()!.startsWith(WORKTREE_PREFIX))
    .map((p) => p.split("/").pop()!.slice(WORKTREE_PREFIX.length));
}

async function allNames(): Promise<string[]> {
  const set = new Set<string>([
    ...(await discoverEditable()),
    ...(await discoverRegistered()).keys(),
    ...(await worktreeNames()),
  ]);
  return [...set].sort();
}

// ---------- status ----------

type Status = "draft" | "changed" | "pending-activation" | "up-to-date" | "saved" | "branch-only";

interface ExtState {
  name: string;
  status: Status;
  editable: boolean;
  registered?: Registered;
  branch: boolean;
  worktree?: string;
  dirty: boolean;
}

async function stateOf(name: string, registered: Map<string, Registered>, wts: Worktree[]): Promise<ExtState> {
  const reg = registered.get(name);
  const ed = editablePath(name);
  const editable = await exists(ed);
  const wt = managedWorktree(wts, name)?.path;
  let status: Status;
  if (editable) {
    if (reg && (await equalTrees(ed, reg.original))) status = "up-to-date";
    else if (wt && (await equalTrees(ed, join(wt, REL_EXT_DIR, name)))) status = "pending-activation";
    else status = reg ? "changed" : "draft";
  } else if (reg) status = "saved";
  else status = "branch-only";
  return {
    name,
    status,
    editable,
    registered: reg,
    branch: await branchExists(branchOf(name)),
    worktree: wt,
    dirty: wt ? await isDirty(wt) : false,
  };
}

const STATUS_LABEL: Record<Status, string> = {
  draft: "draft (not saved)",
  changed: "changed (unsaved)",
  "pending-activation": "saved, needs nixos-rebuild",
  "up-to-date": "up-to-date (active)",
  saved: "saved (nix)",
  "branch-only": "branch only",
};

// ---------- actions (each returns a one-line report) ----------

const ok = (m: string) => `✓ ${m}`;
const skip = (m: string) => `• ${m}`;
const fail = (m: string) => `✗ ${m}`;

async function newOne(name: string, ctx: ExtensionCommandContext): Promise<string> {
  const reg = (await discoverRegistered()).get(name);
  if (reg || (await exists(editablePath(name)))) return fail(`${name} already exists`);
  await mkdir(editablePath(name), { recursive: true });
  await writeFile(
    join(editablePath(name), "index.ts"),
    `import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("${name}", {
    description: "${name} extension",
    handler: async (_args, ctx) => {
      ctx.ui.notify("${name}: hello", "info");
    },
  });
}
`,
  );
  return ok(`${name}: created ${editablePath(name)}`);
}

async function editOne(name: string): Promise<string> {
  const reg = (await discoverRegistered()).get(name);
  if (!reg) return fail(`${name} is not a saved extension; use /ext new ${name}`);
  if (await exists(editablePath(name))) return skip(`${name} already has an editable copy`);
  await copyTree(reg.original, editablePath(name));
  return ok(`${name}: editable copy created from ${reg.original}`);
}

async function saveOne(name: string): Promise<string> {
  const ed = editablePath(name);
  if (!(await exists(ed))) return fail(`${name}: no editable copy to save`);
  const reg = (await discoverRegistered()).get(name);
  if (reg && (await equalTrees(ed, reg.original))) return skip(`${name}: already up-to-date, nothing to save`);

  if (!(await git(["cat-file", "-e", `${CONFIG.baseBranch}:${REL_REGISTRY}`])).ok) {
    return fail(`${name}: ${CONFIG.baseBranch} has no ${REL_REGISTRY}; stopping`);
  }

  // Branch/worktree preflight. Reuse only when nothing is uncommitted.
  const br = branchOf(name);
  const wt = worktreePathOf(name);
  const wts = await listWorktrees();
  const current = managedWorktree(wts, name);
  if (current && current.path !== wt) return fail(`${name}: ${br} is checked out at ${current.path}; stopping`);
  if (!current && (await exists(wt))) return fail(`${name}: ${wt} exists but is not a worktree of ${br}; stopping`);
  if (current && (await isDirty(wt))) {
    return fail(`${name}: ${wt} has uncommitted changes; run /ext commit ${name} first (stopping to avoid losing work)`);
  }

  if (!current) {
    const args = (await branchExists(br))
      ? ["worktree", "add", wt, br]
      : ["worktree", "add", "-b", br, wt, CONFIG.baseBranch];
    const r = await git(args);
    if (!r.ok) return fail(`${name}: git worktree add failed: ${r.err}`);
  }

  // Verbatim copy + registration.
  await copyTree(ed, join(wt, REL_EXT_DIR, name));
  const regFile = join(wt, REL_REGISTRY);
  const text = await readFile(regFile, "utf8");
  const next = addRegistration(text, name);
  if (next !== text) await writeFile(regFile, next);

  const parse = await sh("nix-instantiate", ["--parse", regFile]);
  if (!parse.ok) return fail(`${name}: files written to ${wt} but ${REL_REGISTRY} does not parse: ${parse.err}`);
  return ok(`${name}: saved to ${wt} (branch ${br}, uncommitted). Run nixos-rebuild, then /ext clean ${name}.`);
}

/** Inserts a registration line inside the managed block; idempotent. */
function addRegistration(text: string, name: string): string {
  if (text.includes(`(mkStub "${name}" `)) return text;
  const lines = text.split("\n");
  const begin = lines.findIndex((l) => l.trim().startsWith(BEGIN_MARK));
  const end = lines.findIndex((l) => l.trim().startsWith(END_MARK));
  if (begin < 0 || end < 0 || end < begin) {
    throw new Error(`${REL_REGISTRY} is missing the "${BEGIN_MARK}" / "${END_MARK}" markers`);
  }
  const indent = lines[end].match(/^\s*/)![0];
  lines.splice(end, 0, `${indent}(mkStub "${name}" ./agent/extensions/${name})`);
  return lines.join("\n");
}

async function commitOne(name: string, desc: string | undefined): Promise<string> {
  const wt = managedWorktree(await listWorktrees(), name)?.path;
  if (!wt) return fail(`${name}: no worktree; run /ext save ${name} first`);
  if (!(await isDirty(wt))) return skip(`${name}: nothing to commit`);
  const msg = `feat(programs/pi): ${desc ?? `Add ${name} extension`}`;
  const add = await git(["add", "-A"], wt);
  if (!add.ok) return fail(`${name}: git add failed: ${add.err}`);
  const c = await git(["commit", "-q", "-m", msg], wt);
  if (!c.ok) return fail(`${name}: git commit failed: ${c.err}`);
  return ok(`${name}: committed "${msg}" on ${branchOf(name)}`);
}

async function cleanOne(name: string, registered: Map<string, Registered>): Promise<string> {
  const reg = registered.get(name);
  const ed = editablePath(name);
  const hasEd = await exists(ed);
  // Only an activated extension (nixos-rebuild has put the saved copy in the store) may be cleaned.
  const activated = !!reg && (!hasEd || (await equalTrees(ed, reg.original)));
  if (!activated) {
    return hasEd
      ? skip(`${name}: kept, editable copy differs from the active nix copy (not activated, or has changes)`)
      : skip(`${name}: nothing to clean (not active in nix)`);
  }
  const notes: string[] = [];
  if (hasEd) {
    await rm(ed, { recursive: true, force: true });
    notes.push("removed editable copy");
  }
  const wt = managedWorktree(await listWorktrees(), name)?.path;
  const br = branchOf(name);
  if (wt && (await isDirty(wt))) return skip(`${name}: ${notes.join(", ")}; kept worktree (uncommitted changes)`);
  if (!(await isMerged(br)) && (await branchExists(br))) {
    return skip(`${name}: ${notes.join(", ")}; kept ${br} (not merged into ${CONFIG.baseBranch})`);
  }
  if (wt) {
    const r = await git(["worktree", "remove", wt]);
    if (!r.ok) return fail(`${name}: ${notes.join(", ")}; worktree remove failed: ${r.err}`);
    notes.push("removed worktree");
  }
  if (await branchExists(br)) {
    const r = await git(["branch", "-D", br]);
    if (!r.ok) return fail(`${name}: ${notes.join(", ")}; branch delete failed: ${r.err}`);
    notes.push(`deleted ${br}`);
  }
  return ok(`${name}: ${notes.join(", ") || "nothing to remove"}`);
}

async function purgeOne(name: string): Promise<string> {
  const notes: string[] = [];
  const ed = editablePath(name);
  if (await exists(ed)) {
    await rm(ed, { recursive: true, force: true });
    notes.push("removed editable copy");
  }
  const wt = managedWorktree(await listWorktrees(), name)?.path;
  if (wt) {
    const r = await git(["worktree", "remove", "--force", wt]);
    if (!r.ok) return fail(`${name}: ${notes.join(", ")}; worktree remove failed: ${r.err}`);
    notes.push("removed worktree");
  }
  if (await branchExists(branchOf(name))) {
    const r = await git(["branch", "-D", branchOf(name)]);
    if (!r.ok) return fail(`${name}: ${notes.join(", ")}; branch delete failed: ${r.err}`);
    notes.push(`deleted ${branchOf(name)}`);
  }
  return ok(`${name}: ${notes.join(", ") || "nothing to purge"}`);
}

async function listText(onlyChanged: boolean): Promise<string> {
  const registered = await discoverRegistered();
  const wts = await listWorktrees();
  const rows: string[] = [];
  for (const name of await allNames()) {
    const s = await stateOf(name, registered, wts);
    if (onlyChanged && !["draft", "changed"].includes(s.status) && !s.dirty) continue;
    const where = [s.branch ? branchOf(name) : "", s.worktree ? (s.dirty ? "worktree dirty" : "worktree clean") : ""]
      .filter(Boolean)
      .join(", ");
    rows.push(
      [
        name.padEnd(20),
        (s.registered ? "original: yes" : "original: no ").padEnd(18),
        (s.editable ? `${name}': yes` : `${name}': no `).padEnd(16),
        STATUS_LABEL[s.status].padEnd(30),
        where,
      ].join(" "),
    );
  }
  if (rows.length === 0) return onlyChanged ? "No changed extensions." : "No extensions.";
  return ["NAME                 ORIGINAL           EDITABLE         STATUS                         BRANCH / WORKTREE", ...rows].join("\n");
}

// ---------- command dispatch ----------

async function dispatch(args: string, ctx: ExtensionCommandContext): Promise<void> {
  const [sub = "list", arg1, ...restArgs] = args.trim().split(/\s+/).filter(Boolean);
  const notify = (msg: string, level: "info" | "warning" | "error" = "info") => ctx.ui.notify(msg, level);
  // Per-item errors are reported as a failed line instead of aborting the batch.
  const safe = async (name: string, fn: () => Promise<string>) => {
    try {
      return await fn();
    } catch (e: any) {
      return fail(`${name}: ${e?.message ?? e}`);
    }
  };
  const report = (lines: string[]) => notify(lines.join("\n"), lines.some((l) => l.startsWith("✗")) ? "warning" : "info");

  if (sub === "help") {
    return notify(HELP_TEXT);
  }

  if (sub === "list") {
    return notify(await listText(arg1 === "changed"));
  }

  if (sub === "reload") {
    await ctx.reload(); // code after reload belongs to the old runtime; keep this last
    return;
  }

  if (!SUBCOMMANDS.includes(sub)) {
    return notify(`Unknown subcommand "${sub}". Use: ${SUBCOMMANDS.join(", ")}`, "error");
  }
  if (arg1 && !NAME_RE.test(arg1)) return notify(`Invalid name "${arg1}" (use lowercase letters, digits, dashes)`, "error");

  if (sub === "adopt") {
    const found = (await discoverLoose()).filter((l) => !arg1 || l.name === arg1);
    if (found.length === 0) return notify(arg1 ? `No loose extension named ${arg1}` : "No loose extensions.");
    const lines = [];
    for (const l of found) lines.push(await safe(l.name, () => adoptOne(l)));
    report(lines);
    if (lines.some((l) => l.startsWith("✓"))) {
      notify("Reloading extensions…");
      await ctx.reload(); // code after reload belongs to the old runtime; keep this last
    }
    return;
  }

  if (sub === "new" || sub === "edit") {
    if (!arg1) return notify(`Usage: /ext ${sub} <name>`, "error");
    const line = sub === "new" ? await newOne(arg1, ctx) : await editOne(arg1);
    notify(line, line.startsWith("✗") ? "error" : "info");
    if (line.startsWith("✓")) {
      notify("Reloading extensions…");
      await ctx.reload(); // code after reload belongs to the old runtime; keep this last
    }
    return;
  }

  const registered = await discoverRegistered();
  const targets = arg1 ? [arg1] : await allNames();

  if (sub === "save") {
    const wts = await listWorktrees();
    const list = [];
    for (const n of targets) {
      const s = await stateOf(n, registered, wts);
      if (!arg1 && (!s.editable || s.status === "up-to-date" || s.status === "pending-activation")) continue;
      list.push(n);
    }
    if (list.length === 0) return notify("Nothing to save.");
    const lines = [];
    for (const n of list) lines.push(await safe(n, () => saveOne(n)));
    return report(lines);
  }

  if (sub === "commit") {
    const lines = [];
    let desc: string | undefined = restArgs.join(" ").trim() || undefined;
    const named = arg1 ? managedWorktree(await listWorktrees(), arg1) : undefined;
    if (arg1 && !desc && ctx.hasUI && named?.path && (await isDirty(named.path))) {
      const input = await ctx.ui.input(`Commit description for ${arg1}`, `Add ${arg1} extension`);
      if (input === undefined) return notify("Commit cancelled.");
      desc = input.trim() || undefined;
    }
    // Batch commit only touches extensions that have uncommitted work.
    const wts = await listWorktrees();
    const commitTargets = arg1 ? targets : targets.filter((n) => managedWorktree(wts, n)?.path);
    for (const n of commitTargets) lines.push(await safe(n, () => commitOne(n, desc)));
    if (lines.length === 0) return notify("Nothing to commit.");
    return report(lines);
  }

  if (sub === "clean") {
    const lines = [];
    for (const n of targets) lines.push(await safe(n, () => cleanOne(n, registered)));
    return report(lines);
  }

  if (sub === "purge") {
    if (targets.length === 0) return notify("Nothing to purge.");
    if (!ctx.hasUI) return notify("purge needs interactive confirmation; run it from the TUI.", "error");
    const yes = await ctx.ui.confirm(
      "Purge extension(s)?",
      `${targets.join(", ")}\nThis deletes unsaved editable copies and their worktree/branch. It cannot be undone.`,
    );
    if (!yes) return notify("Purge cancelled.");
    const lines = [];
    for (const n of targets) lines.push(await safe(n, () => purgeOne(n)));
    return report(lines);
  }
}

// ---------- extension entry ----------

export default async function (pi: ExtensionAPI) {
  pi.registerCommand("ext", {
    description: "Manage PI extensions (new, edit, reload, list, save, commit, clean, purge). Run /ext help for details",
    getArgumentCompletions: (prefix: string) => {
      if (prefix.includes(" ")) return null;
      return SUBCOMMANDS.filter((s) => s.startsWith(prefix)).map((s) => ({ value: s, label: s }));
    },
    handler: async (args: string, ctx: ExtensionCommandContext) => dispatch(args, ctx),
  });

  // Loose extensions are adopted before drafts load, so they come up as drafts in this start.
  const adopted: string[] = [];
  for (const l of await discoverLoose()) {
    try {
      adopted.push(await adoptOne(l));
    } catch (e: any) {
      adopted.push(fail(`${l.name}: ${e?.message ?? e}`));
    }
  }
  if (adopted.length > 0) {
    pi.on("session_start", async (_event, ctx) => {
      ctx.ui.notify(`Extension Manager adopted loose extensions:\n${adopted.join("\n")}\nIf a command shows twice, run /ext reload once.`, "info");
    });
  }

  // Drafts: editable copies with no registration yet. Their loader is this extension.
  const registered = await discoverRegistered();
  const loadErrors: string[] = [];
  for (const name of await discoverEditable()) {
    if (registered.has(name)) continue; // the stub loads the editable copy
    try {
      const mod = await import(`${await entryOf(editablePath(name))}?v=${Date.now()}`);
      await mod.default(pi);
    } catch (e: any) {
      loadErrors.push(`${name}: ${e?.message ?? e}`);
    }
  }
  if (loadErrors.length > 0) {
    pi.on("session_start", async (_event, ctx) => {
      ctx.ui.notify(`Draft extension(s) failed to load:\n${loadErrors.join("\n")}`, "error");
    });
  }
}
