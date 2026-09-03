{
  config,
  lib,
  ...
}: let
  defaultConfiguration = {
    editor = "nvim";
    isTerminalBased = true;
  };
  commonModule = {
    program,
    pkgs,
    ...
  }:
    with program;
    with lib; let
      package = getPackage {inherit pkgs metadata;};
    in {
      environment.variables = {
        EDITOR = "${getExe' package program.metadata.editor}";
      };
    };
in {
  anvil.programs.editor = {
    metadata = defaultConfiguration;
    getPackage = {
      metadata,
      pkgs,
      ...
    }:
      config.anvil.programs.${metadata.editor}.getPackage {inherit pkgs;};
    programs = {program, ...}: [program.metadata.editor];
    nixos = commonModule;
    darwin = commonModule;
  };

  flake.wrappers.editor = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];
    config.package = config.anvil.programs.editor.getPackage {
      inherit pkgs;
      metadata = defaultConfiguration;
    };
  };
}
