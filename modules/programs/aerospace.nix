{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.aerospace = {
    getPackage = self.wrappers.aerospace.wrap;
    home = {...}: {
      programs.aerospace.enable = true;
      xdg.configFile."aerospace/aerospace.toml".text = self.dotfiles.aerospace.default {};
    };
    darwin = {program, pkgs, ...}: let
      package = program.getPackage { inherit pkgs; };
    in {
      environment.systemPackages = [ package ];
    };
  };

  flake.wrappers.aerospace = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.default
      self.declarations.desktop
    ];
    package = pkgs.aerospace;
  };

  perSystem = {pkgs, ...}: {
    wrappers.packages.aerospace =
      !(pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isDarwin);
  };
}
