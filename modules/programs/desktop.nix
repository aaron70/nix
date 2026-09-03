{
  inputs,
  self,
  config,
  lib,
  ...
}:
with lib; let
  defaultConfiguration = {
    desktop.name = "gnome";
  };
in {
  anvil.programs.desktop = {
    metadata = defaultConfiguration;
    programs = {program, ...}: [
      program.metadata.desktop.name
    ];
    getPackage = {
      pkgs,
      metadata,
      ...
    }:
      config.anvil.programs.${metadata.desktop.name}.getPackage {
        inherit pkgs;
        configuration = metadata.desktop.config {inherit pkgs;};
      };
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
      ];
    };
    darwin = {pkgs, ...}: {
      environment.systemPackages = [
        (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
      ];
    };
  };

  flake.wrappers.desktop = {...}:
    with defaultConfiguration; {
      imports = [
        self.wrapperModules.${desktop.name}
      ];
    };
}
