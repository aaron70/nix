{lib, ...}:
with lib; {
  flake.dotfiles.scripts = {
    "hydrate-paths" = readFile ./hydrate-paths.sh;
    "custom-fzf-preview" = readFile ./custom-fzf-preview.sh;
    "cdfzf" = readFile ./cdfzf.sh;
  };
}
