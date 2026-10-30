{lib, ...}:
with lib; {
  flake.dotfiles.herdr.scripts.toggle-herdr-popup = {...}: readFile ./toggle-herdr-popup.sh;
}
