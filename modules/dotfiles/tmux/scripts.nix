{lib, ...}:
with lib; {
  flake.dotfiles.tmux.scripts.toogle-tmux-popup = { ... }: readFile ./toogle-tmux-popup.sh;
  flake.dotfiles.tmux.scripts.sessions = { ... }: readFile ./sessions.sh;
}
