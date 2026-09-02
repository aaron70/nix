{lib, ...}:
with lib; {
  flake.dotfiles.tmux.scripts.toggle-tmux-popup = { ... }: readFile ./toggle-tmux-popup.sh;
  flake.dotfiles.tmux.scripts.sessions = { ... }: readFile ./sessions.sh;
}
