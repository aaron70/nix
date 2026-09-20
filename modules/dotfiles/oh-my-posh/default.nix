{
  self,
  lib,
  ...
}:
with lib; {
  flake.dotfiles.oh-my-posh.default = {colors, ...}:
    self.dotfiles.oh-my-posh.theme {
      inherit colors;
      pathStyle = "folder";
      promptGlyph = "󱞩 ";
      powerline = true;
      upstreamIcon = true;
      osIcon = true;
    };

  flake.dotfiles.oh-my-posh.activationScript.zsh = {
    pkgs,
    prompt,
    ...
  }: ''
    function detect_terminal() {
      if [ -n "$TMUX" ]; then
        tty_path=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
        term_name=$(tmux display-message -p '#{client_termname}' 2>/dev/null)
      else
        tty_path=$(tty 2>/dev/null)
        term_name="$TERM"
      fi

      case "$tty_path" in
        /dev/tty[0-9]*)
            echo "linux_terminal"
            return
            ;;
      esac

      case "$TERM_PROGRAM" in
        Apple_Terminal) echo "apple_terminal"; return ;;
        iTerm.app)      echo "iterm2"; return ;;
      esac

      case "$term_name" in
        xterm-kitty)   echo "kitty";   return ;;
        xterm-ghostty) echo "ghostty"; return ;;
        foot|foot-extra) echo "foot"; return ;;
      esac

      # Fallback to env vars, only meaningful outside tmux
      if [ -z "$TMUX" ]; then
        if [ -n "$KITTY_WINDOW_ID" ]; then
            echo "kitty"; return
        elif [ -n "$GHOSTTY_RESOURCES_DIR" ] || [ "$TERM_PROGRAM" = "ghostty" ]; then
            echo "ghostty"; return
        fi
      fi

      echo "unknown_terminal"
    }

    case "$(detect_terminal)" in
      apple_terminal|linux_terminal)
        eval "$(${getExe' (prompt.getPackage {
      inherit pkgs;
      tty = true;
    }) "oh-my-posh"} init zsh)"
        ;;
      *)
        eval "$(${getExe' (prompt.getPackage {
      inherit pkgs;
      tty = false;
    }) "oh-my-posh"} init zsh)"
        ;;
    esac
  '';
}
