{ lib, ... }:
with lib; {
  flake.dotfiles.zsh.default =
    {
      pkgs,
      activationScripts ? [],
      prompt,
      multiplexer,
      ...
    }:
    with pkgs; ''
      # Profiling: ZSH_PROFILE_STARTUP=1 zsh -i -c exit
      [[ -n ''${ZSH_PROFILE_STARTUP:-} ]] && zmodload zsh/zprof

      # Required by the (#q...) glob qualifiers in the staleness checks below
      # (_anvil_cache_source and .zcompdump). Without it those qualifiers are read
      # as literal text and every check silently degenerates to always-true,
      # regenerating caches on every startup.
      setopt extended_glob

      # XDG cache helpers — cache eval outputs to avoid forking every startup
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      [[ -d $XDG_CACHE_HOME/zsh ]] || mkdir -p "$XDG_CACHE_HOME/zsh" 2>/dev/null || true

      _anvil_cache_source() {
        local name="$1"; shift
        local f="$XDG_CACHE_HOME/zsh/$name.zsh"
        # Regenerate if missing or older than 24h (glob qualifier N.mh+24)
        if [[ ! -f "$f" || -n "$f"(#qN.mh+24) ]]; then
          # Write via temp+rename so concurrent shells never source or zcompile a
          # half-written cache; -s guards against caching an empty generation.
          local tmp="$f.tmp.$$"
          if "$@" > "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
            mv -f "$tmp" "$f"
            # Detach via subshell — braces would register the job in THIS shell
            # and leak "[n] pid / [n] + exit N" notifications before the prompt.
            [[ -s "$f" ]] && ( zcompile "$f" >/dev/null 2>&1 & )
          else
            rm -f "$tmp" 2>/dev/null
            return
          fi
        fi
        source "$f"
      }

      # Load zsh-defer early so subsequent plugins can be deferred
      source ${zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh

      ${concatStringsSep "\n" activationScripts}

      # Make zsh-completions available BEFORE compinit so its #compdef
      # registrations end up in the dump — prepending after compinit leaves the
      # plugin ~inert (functions resolve lazily, but nothing registers them).
      fpath=(${zsh-completions}/share/zsh/site-functions $fpath)

      # Completion — single cached compinit, compiled
      autoload -Uz compinit
      # Full regen when the dump is missing OR stale (>24h) — a missing dump used to
      # fall through to the same fast `-C` path as a freshly-regenerated one, which is
      # wrong on a brand-new $HOME (new machine, wiped cache, etc).
      _anvil_zcompdump=''${ZDOTDIR:-$HOME}/.zcompdump
      if [[ ! -f "$_anvil_zcompdump" || -n "$_anvil_zcompdump"(#qN.mh+24) ]]; then
        compinit -i
      else
        compinit -C -i
      fi
      # Compile the dump in a detached subshell (braces would leak job-control
      # notifications like "[2] + exit 1 zcompile …" into interactive startups).
      [[ -s "$_anvil_zcompdump" ]] && ( zcompile "$_anvil_zcompdump" >/dev/null 2>&1 & )
      unset _anvil_zcompdump
      zmodload -i zsh/complist

      # ==============================
      # Environment Variables
      # ==============================

      HISTFILE=$HOME/.zsh_history
      HISTSIZE=100000
      SAVEHIST=$HISTSIZE

      # NOTE: zsh-autosuggestions reads these once at load time — they must stay
      # assigned BEFORE the deferred `zsh-defer source` of the plugin below.
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

      CORRECT_IGNORE_FILE=".*"
      CORRECT_IGNORE="_*"

      # ==============================
      # ZSH Options
      # ==============================

      setopt auto_cd
      setopt correct
      setopt interactive_comments

      # History — kept as a compatibility fallback ($HISTFILE still feeds
      # zsh-autosuggestions' "history" strategy and any tool that reads it directly).
      # Atuin owns interactive search (ctrl-r / up-arrow); see the plugin block below.
      setopt hist_expire_dups_first
      setopt hist_find_no_dups
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_reduce_blanks
      setopt hist_save_no_dups
      setopt hist_verify
      # share_history implies inc_append_history semantics
      setopt share_history
      # Timestamped entries in $HISTFILE (better atuin imports / tooling fidelity)
      setopt extended_history

      # Completion / suggestions
      setopt auto_list
      # (auto_menu intentionally not set: ':completion:* menu no' below disables
      # zsh's own menu because fzf-tab owns it)
      setopt always_to_end

      # Vi-mode latency: zsh-vi-mode OVERWRITES KEYTIMEOUT during its init
      # (KEYTIMEOUT=1 under the default NEX readkey engine), so setting
      # KEYTIMEOUT here has no lasting effect. The knob that matters is
      # ZVM_KEYTIMEOUT (in SECONDS, default 0.4 — explains any jk/plain-j lag);
      # set it next to ZVM_VI_INSERT_ESCAPE_BINDKEY below if mode switching or
      # surround combos ever feel sluggish.

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      # fzf-tab previews — eza/bat when available, fall back to ls
      if command -v eza &>/dev/null; then
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always --group-directories-first $realpath 2>/dev/null || ls --color $realpath'
        zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then eza --icons --color=always --group-directories-first $realpath 2>/dev/null || ls --color $realpath; else bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath 2>/dev/null | head -n 100; fi'
      else
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
      fi
      zstyle ':fzf-tab:*' use-fzf-default-opts yes
      zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --info=right --border

      # ==============================
      # Vi Mode (zsh-vi-mode plugin — sourced last, see Plugins section)
      # ==============================
      # Keep the `jk` escape muscle memory from the old hand-rolled config.
      ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
      # Cursor shape (block=normal, beam=insert) is the plugin's default behavior —
      # no manual zle-keymap-select/zle-line-init functions needed anymore.
      # ZVM_VI_EDITOR=nvim   # uncomment if $EDITOR isn't already nvim (used by `vv`)
      # If `ds"`/`cs"'`-style surround combos feel laggy or too eager to fire, tune
      # ZVM_KEYTIMEOUT here — see the zsh-vi-mode README for units/defaults.

      # zsh-vi-mode runs its own `bindkey -v` on init and will silently clobber any
      # keybinding set before it loads (this is a known upstream interaction — see
      # jeffreytse/zsh-vi-mode README, "Since ... this plugin will overwrite the
      # previous key bindings"). It calls this function automatically once it's done,
      # so re-apply everything ZVM might have stomped on here instead of above.
      function zvm_after_init() {
        # Autosuggestions
        bindkey -M viins '^y' autosuggest-accept
        bindkey -M viins '^ ' autosuggest-accept
        # Edit command line in $EDITOR
        bindkey -M viins '^e' edit-command-line
        bindkey -M vicmd '^e' edit-command-line
        # Completion-friendly space
        bindkey -M viins ' ' magic-space
        # Atuin — ctrl-r and up-arrow, both insert and normal mode. The widget was
        # renamed across atuin versions (_atuin_search_widget -> atuin-search);
        # bind whichever exists so a version bump can't silently kill the keys.
        local _anvil_atuin_widget=
        (( $+widgets[_atuin_search_widget] )) && _anvil_atuin_widget=_atuin_search_widget
        (( $+widgets[atuin-search] )) && _anvil_atuin_widget=atuin-search
        if [[ -n "$_anvil_atuin_widget" ]]; then
          bindkey -M viins '^r' "$_anvil_atuin_widget"
          bindkey -M vicmd  '^r' "$_anvil_atuin_widget"
          bindkey -M viins '^[[A' "$_anvil_atuin_widget"
          bindkey -M vicmd  '^[[A' "$_anvil_atuin_widget"
        else
          echo "zsh: no known atuin widget found (checked _atuin_search_widget / atuin-search)" >&2
        fi
        # Note: vicmd `k`/`j` are intentionally left as plain vi cursor movement
        # (correct vi semantics) rather than remapped to history stepping, now that
        # Atuin owns search. Flag if you'd rather have them step history instead.
      }

      # ==============================
      # Keybindings — good terminal
      # ==============================
      # (actual bindkey calls for these live in zvm_after_init() above; these just
      # register the widgets so they exist by the time that hook runs)

      # Edit command in $EDITOR
      autoload -Uz edit-command-line
      zle -N edit-command-line

      # Bracketed paste + URL quoting (widget-name overrides, no bindkey needed)
      autoload -Uz bracketed-paste-magic url-quote-magic
      zle -N bracketed-paste bracketed-paste-magic
      zle -N self-insert url-quote-magic

      # ==============================
      # Hooks — always on. Each function guards itself against irrelevant
      # directories (auto_venv/auto_nvm only act when a .venv/.nvmrc exists), so
      # there's no separate env-var switch to remember to flip. This file is
      # generated — to disable one on a specific machine, filter it out of the
      # hook array from ~/.zshrc.local instead of editing here:
      #   chpwd_hooks=(''${chpwd_hooks:#auto_venv})
      # ==============================
      autoload -Uz add-zsh-hook

      function auto_venv() {
        # Deactivate when leaving the venv's project tree. Path-prefix match — a
        # plain substring test would treat sibling dirs (proj vs proj-v2) as
        # "still inside" and keep a stale venv active.
        if [[ -n "$VIRTUAL_ENV" && "$PWD" != "''${VIRTUAL_ENV:h}"(|/*) ]]; then
          deactivate 2>/dev/null || true
          return
        fi
        [[ -n "$VIRTUAL_ENV" ]] && return
        local dir="$PWD"
        while [[ "$dir" != "/" ]]; do
          if [[ -f "$dir/.venv/bin/activate" ]]; then
            source "$dir/.venv/bin/activate"
            return
          fi
          dir="''${dir:h}"
        done
      }

      function auto_nvm() {
        # Prefer fnm (3-60ms) over nvm.sh (300-1500ms). This shim keeps .nvmrc compat
        # without eager sourcing. Uncomment if you still use nvm.sh.
        # [[ -f .nvmrc ]] && command -v nvm &>/dev/null && nvm use
        # NOTE: mise users should rely on `mise activate zsh` instead — its
        # legacy_version_file support honors .nvmrc automatically. Never call
        # `mise use` from a hook: it WRITES a config file into the project on cd.
        if [[ -f .nvmrc ]] && command -v fnm &>/dev/null; then
          fnm use --silent-if-unchanged 2>/dev/null || true
        fi
      }

      add-zsh-hook chpwd auto_venv
      add-zsh-hook chpwd auto_nvm

      # ==============================
      # Plugins — deferred for speed (zsh-defer)
      # Good terminal: autosuggestions + fzf-tab + fast highlight + real vi-mode
      # ==============================

      # Defer UI plugins past first prompt.
      # Order matters: fzf-tab must load after compinit (already true) but BEFORE any
      # plugin that wraps zle widgets (autosuggestions, fast-syntax-highlighting) —
      # see Aloxaf/fzf-tab README, "Important" section. zsh-vi-mode must load LAST,
      # since it takes over bindkey -v and would otherwise clobber the others.
      zsh-defer source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zsh-defer source ${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      # fast-syntax-highlighting; ~200KB, faster than zsh-syntax-highlighting
      zsh-defer source ${zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
      # zsh-defer  source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      # zsh-vi-mode — real vim editing (surround, text objects, `vv` to edit in $EDITOR)
      zsh-defer source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      # No prompt — configure manually if desired:
      #   starship: eval "$(starship init zsh)"  (or _anvil_cache_source starship starship init zsh)
      #   oh-my-posh: eval "$(oh-my-posh init zsh --config ~/.config/omp.json)"
      #   p10k: add instant-prompt snippet at top of this file

      # Allow per-user overrides without editing this dotfile
      [[ -f ''${ZDOTDIR:-$HOME}/.zshrc.local ]] && source ''${ZDOTDIR:-$HOME}/.zshrc.local

      # NOTE: zprof only sees work done while sourcing this file — plugins loaded
      # through zsh-defer run AFTER this point and are invisible to the report.
      [[ -n ''${ZSH_PROFILE_STARTUP:-} ]] && zprof | head -n 40

      ${prompt.activationScript}

      ${multiplexer.activationScript}
    '';

  # Ready-made activation snippets for `default`'s `activationScripts` parameter.
  # Each guards on PATH because under Nix a bare store-path check is always true
  # once the tool is in the closure — only `command -v` tells you the machine
  # actually wants that tool's shell integration.
  # flake.dotfiles.zsh.toolInit = {pkgs, ...}:
  #   with pkgs; {
  #     fzf = "command -v fzf &>/dev/null && _anvil_cache_source fzf ${fzf}/bin/fzf --zsh";
  #     zoxide = "command -v zoxide &>/dev/null && _anvil_cache_source zoxide ${zoxide}/bin/zoxide init zsh --cmd cd";
  #     direnv = "command -v direnv &>/dev/null && _anvil_cache_source direnv ${direnv}/bin/direnv hook zsh";
  #     # First time on a new machine: `atuin import auto` seeds it from ~/.zsh_history.
  #     # `atuin login` (or `atuin register`) opts that machine into encrypted sync —
  #     # worth wiring the sync key through sops-nix later so it's provisioned, not manual.
  #     atuin = "command -v atuin &>/dev/null && _anvil_cache_source atuin ${atuin}/bin/atuin init zsh";
  #   };
}
