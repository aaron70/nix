{
  inputs,
  self,
  config,
  lib,
  ...
} @ global:
with lib; let
  defaultConfiguration = {
    desktop.name = "niri";
  };
  commonModule = {pkgs, ...}: {
    environment.systemPackages = [
      (global.config.anvil.programs.zen.getPackage {inherit pkgs;})
    ];
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
    nixos = {...}: {
      imports = [commonModule];
      services.displayManager.gdm.enable = true;
    };
    darwin = commonModule;
  };
}
