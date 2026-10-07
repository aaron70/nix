{...}: {
  flake.dotfiles.atuin.default = {...}: ''
    dialect = "us"

    ## Sync
    auto_sync = true
    sync_frequency = "5m"                  # "0" syncs after every command
    sync_address = "https://api.atuin.sh"  # change if you self-host

    ## Search behavior
    invert = false
    enter_accept = true
    filter_mode = "global"
    filter_mode_shell_up_key_binding = "session"
    search_mode = "daemon-fuzzy"
    workspaces = true                      # git-repo-aware filtering

    ## Keymap
    keymap_mode = "vim-normal"
    keymap_cursor = { emacs = "blink-block", vim_insert = "steady-bar", vim_normal = "steady-block" }

    ## Appearance
    style = "compact"
    inline_height = 40                     # height of the search window
    show_preview = true

    ## Hygiene (important when syncing across machines)
    secrets_filter = true                  # drops AWS keys, GitHub tokens, etc.
    history_filter = [
      "export .*(TOKEN|SECRET|KEY|PASSWORD)",
      "^(ls|cd|pwd|clear|exit)$",
    ]
    cwd_filter = []                        # e.g. ["^/tmp"] to ignore directories
    store_failed = true

    ## Misc
    update_check = false

    [daemon]
    enabled = true
    autostart = true

    [keys]
    prefix = "a"

    [ui]
    columns = ["time", "command", "host"]

    [tmux]
    enabled = true
  '';
}
