{lib, ...}:
with lib; {
  flake.dotfiles.tmux.scripts.toggle-tmux-popup = _: readFile ./toggle-tmux-popup.sh;
  flake.dotfiles.tmux.scripts.sessions = _: readFile ./sessions.sh;
}
