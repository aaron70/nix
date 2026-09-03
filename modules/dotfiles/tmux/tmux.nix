{lib, ...}:
with lib; {
  flake.dotfiles.tmux.activationScript.zsh = {
    ...
  }: ''
    if [[ "$TMUX" == "" ]]; then
      if [[ "$(tmux ls 2>/dev/null)" == "" ]]; then
        tmux new -s kyoten
      fi
      sesh connect kyoten
    fi
  '';

  flake.dotfiles.tmux.default = {
    pkgs,
    colors,
    ...
  }: {
    prefix = "C-space";
    modeKeys = "vi";
    vimVisualKeys = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.yank
    ];
    terminal = "tmux-256color";
    terminalOverrides = ",xterm-kitty:Tc,xterm-256color:Tc,linux:Tc";
    configBefore = ''
      set -g default-terminal "tmux-256color"
      set -g renumber-windows on  # keep numbering sequential
      set -g focus-events on      # Enable focus events for vim autoread

      # Better pane splitting (and keep current path)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Vim-style pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Theme: status
      set -g status-style bg=${colors.base00},fg=${colors.base03},bright
      set -g status-left " "
      set -g status-right "#[fg=orange,bright]#S "

      # Theme: status (windows)
      set -g window-status-format "●"
      set -g window-status-current-format "●"

      set -g window-status-current-style "#{?window_zoomed_flag,fg=yellow,fg=${colors.base0D}\#,nobold}"
      set -g window-status-bell-style "fg=red,nobold"

      bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
      # NOTE: Commented as it didn't worked well with the {name}' sessions for the floating panes
      # set -g detach-on-destroy off  # don't exit from tmux when closing a session

      bind-key -r f run-shell "sessions"
      bind-key -r l run-shell "toggle-tmux-popup"
      bind-key -r g run-shell 'tmux popup -E -d "#{pane_current_path}" -w "90%" -h "90%" -T "LazyGit" "lazygit"'

      set -gq allow-passthrough on
      set -g visual-activity off
      set-option -g focus-events on
    '';
  };
}
