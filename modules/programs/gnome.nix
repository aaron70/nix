{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.gnome = {
    getPackage = {pkgs, ...}:
      pkgs.gnome-shell;

    nixos = {
      user,
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      imports = [
        (self.lib.installPackages user [package])
      ];
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      services.xserver.xkb.layout = "us";
    };
  };

  flake.wrappers.gnome = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.default
      self.declarations.desktop
    ];
    config.package = pkgs.gnome-shell;
  };
}
