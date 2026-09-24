{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.aerospace = {
    getPackage = self.wrappers.aerospace.wrap;
    home = _: {
      programs.aerospace.enable = true;
      xdg.configFile."aerospace/aerospace.toml".text = self.dotfiles.aerospace.default {};
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
