{lib, ...}:
with lib; {
  flake.dotfiles.herdr.activationScript.zsh = {...}: ''
  '';
  flake.dotfiles.herdr.default = {...}: ''
    onboarding = false

    [terminal]
    shell_mode = "auto"
    new_cwd = "follow"
    kitty_graphics = true

    [worktrees]
    directory = "~/.herdr/worktrees"

    [keys]
    prefix = "ctrl+space"
    toggle_sidebar = "prefix+a"

    [[keys.command]]
    key = "prefix+g"
    type = "popup"
    command = "lazygit"
    description = "Run lazygit"
    width = "80%"
    height = "80%"

    [[keys.command]]
    key = "prefix+l"
    type = "popup"
    command = "exec \"herdr\""
    description = "Open scratch terminal"
    width = "80%"
    height = "80%"

    [session]
    resume_agents_on_restore = true
    startup_per_agent_delay_ms = 100

    [ui]
    sidebar_start_collapsed = true
    sidebar_collapsed_mode = "compact"

    hide_tab_bar_when_single_tab = false
    tab_bar_position = "bottom"

    [experimental]
    allow_nested = false
  '';
}
