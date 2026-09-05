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
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      services.xserver.xkb.layout = "us";
      environment.systemPackages = [package];
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
