{
  self,
  config,
  lib,
  ...
}:
with lib; let
  defaultConfiguration = {
    terminal.name = "kitty";
  };
in {
  anvil.programs.terminal = {
    metadata = defaultConfiguration;
    programs = {program, ...}: [
      program.metadata.terminal.name
      "shell"
    ];
    getPackage = {
      pkgs,
      metadata,
      ...
    }:
      config.anvil.programs.${metadata.terminal.name}.getPackage {inherit pkgs;};
  };

  flake.wrappers.desktop = {...}:
    with defaultConfiguration; {
      imports = [
        self.wrapperModules.${desktop.name}
      ];
    };
}
