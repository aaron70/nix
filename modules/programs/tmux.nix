{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.tmux = rec {
    getPackage = self.wrappers.tmux.wrap;
    nixos = {
      user,
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
      scriptsPkgs = [
        package
        (pkgs.writeShellScriptBin "sessions" (self.dotfiles.tmux.scripts.sessions {}))
        (pkgs.writeShellScriptBin "toggle-tmux-popup" (self.dotfiles.tmux.scripts.toggle-tmux-popup {}))
      ];
    in {
      imports = [
        (self.lib.installPackages user scriptsPkgs)
      ];
    };
    darwin = nixos;
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
