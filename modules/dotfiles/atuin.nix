{...}: {
  flake.dotfiles.atuin.default = {...}: ''
    dialect = "us"

    invert = false
    enter_accept = true

    filter_mode = "global"
    filter_mode_shell_up_key_binding = "global"

    keymap_mode = "vim-normal"
    keymap_cursor = { emacs = "blink-block", vim_insert = "steady-bar", vim_normal = "steady-block" }

    search_mode = "daemon-fuzzy"

    # height of the search window
    inline_height = 40
    style = "compact"

    [daemon]
    enabled = true
    autostart = true

    [keys]
    prefix = "a"

    [ui]
    columns = ["time", "command"]
  '';
}
