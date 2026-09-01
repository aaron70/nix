{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.tmux = {
    getPackage = self.wrappers.tmux.wrap;
  };
  flake.wrappers.tmux = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      wlib.wrapperModules.tmux
      self.modules.generic.colors
    ];

    config = let
      colors = config.preferences.theme.colors;
    in
      self.dotfiles.tmux.default {inherit pkgs colors;};
  };
}
