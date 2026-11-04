# Extension Manager (`/ext`)

Manages PI extensions through their lifecycle: draft → editable → saved to the
Nix repo → cleaned up. Run `/ext help` in pi for a short summary.

## Concepts

- **Saved extension**: lives in the Nix repo (`modules/dotfiles/pi/agent/extensions/<name>`)
  and is registered in `modules/dotfiles/pi/pi.nix`. It is loaded from the read-only Nix store.
- **Self-management**: the manager is registered in `pi.nix` as a stub like any other extension
  (`mkStub "extension-manager" ...`), so `/ext edit extension-manager` works. Edit it, `/ext reload`,
  then `/ext save extension-manager`. If the editable copy has a syntax error, `/ext` disappears;
  recover by deleting `~/.pi/agent/dev-extensions/extension-manager'` and running `/reload`.
- **Editable copy** (`<name>'`): a writable copy in `~/.pi/agent/dev-extensions/<name>'/`.
  The trailing `'` marks it as editable. When it exists, pi loads it instead of the store copy,
  so you can change it and hot-reload with `/ext reload`.
- **Draft**: an editable copy that is not saved yet (no registration in `pi.nix`).
- **Loose extension**: anything pi auto-loads from `~/.pi/agent/extensions/` (a `<name>/index.ts`
  folder or a `<name>.ts` file). The manager adopts these on start: they are moved to `<name>'` and
  become drafts, so `/ext list`, `save`, `clean`, and `purge` handle them. Always create extensions
  with `/ext new` (or in `dev-extensions/`), not in `~/.pi/agent/extensions/`.
- **Branch / worktree**: saving creates branch `feat/pi-<name>` and worktree
  `~/worktrees/nix/nix-pi-<name>`, both based on `main`. Your main checkout is never touched.

## Typical workflow

1. `/ext new <name>` – create a draft `<name>'` from a template and reload.
2. Edit `~/.pi/agent/dev-extensions/<name>'/index.ts`, then `/ext reload` to test.
3. `/ext save <name>` – copy the files verbatim into the worktree and register them in `pi.nix` (not committed).
4. `/ext commit <name> [description]` – commit the worktree changes on `feat/pi-<name>`.
5. Run `nixos-rebuild` so the saved copy becomes active.
6. `/ext clean <name>` – remove the editable copy, worktree and branch once they are safe to remove.

## Commands

### `/ext help`
Shows the list of subcommands.

### `/ext new <name>`
Creates a new draft `<name>'` with a template `index.ts` (one command named `<name>`),
then reloads extensions. Fails if `<name>` already exists as a saved extension or draft.

### `/ext edit <name>`
Creates an editable copy `<name>'` from the saved extension's files, then reloads.
Use it to change an extension that is already saved. Fails if `<name>` is not saved.
If the editable copy already exists, nothing is changed.

### `/ext adopt [name]`
Moves loose extensions from `~/.pi/agent/extensions/` into drafts, then reloads. Adoption also runs
automatically on start. It never overwrites an existing `<name>'`. If a command shows twice after
adoption, run `/ext reload` once.

### `/ext reload`
Reloads all extensions (same as pi's reload). Use it after editing a `'` copy.

### `/ext list [changed]`
Shows a table with each extension's original (saved) state, editable (`'`) state,
status and branch/worktree. With `changed`, shows only drafts, changed extensions,
and extensions with uncommitted worktree changes.

Statuses:

| Status | Meaning |
| --- | --- |
| `draft (not saved)` | Editable copy only; not registered yet |
| `changed (unsaved)` | Editable copy differs from the saved version |
| `saved, needs nixos-rebuild` | Saved to the worktree; the saved copy is not active yet |
| `up-to-date (active)` | Editable copy equals the active saved version |
| `saved (nix)` | Saved and active; no editable copy |
| `branch only` | Only the `feat/pi-<name>` branch remains |

### `/ext save [name]`
Writes the editable copy into the worktree `nix-pi-<name>` (branch `feat/pi-<name>`,
created from `main` if needed) and registers it in `pi.nix`. Changes are **not committed**.
- Without a name, saves every extension that has an editable copy and is not already up-to-date.
- Stops if the worktree has uncommitted changes, so no work is lost. Run `/ext commit` first.
- Checks that the edited `pi.nix` still parses.

After saving, run `nixos-rebuild`, then `/ext clean <name>`.

### `/ext commit [name] [description]`
Commits all uncommitted changes in the extension's worktree on `feat/pi-<name>`.
The message is `feat(programs/pi): <description>`; the default description is `Add <name> extension`.
- If `description` is omitted in the TUI, you are asked for it.
- Without a name, commits every extension worktree that has changes.

### `/ext clean [name]`
Safe cleanup. Removes the editable copy only when the saved extension is active and
identical to it. It removes the worktree and branch only when the worktree has no
uncommitted changes and the branch is merged into `main`. Otherwise it keeps them and
explains why. It never discards unsaved work.
Without a name, applies to all extensions.

### `/ext purge [name]`
Unsafe cleanup for work you no longer want. Deletes the editable copy, force-removes the
worktree (including uncommitted changes), and force-deletes the branch (`git branch -D`),
whether or not it is merged. Asks for confirmation first; only works in the TUI.
Without a name, applies to all extensions.
