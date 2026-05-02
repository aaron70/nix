{
  inputs,
  self,
  lib,
  ...
}:
with lib; let
  hexColor =
    lib.types.strMatching "^#[0-9a-fA-F]{6}$"
    // {
      description = "6-digit hex color (including '#')";
    };

  base16Slots = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
in {
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      wrapperHelpers = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = {
    # flake.wrapperHelpers.options.configurations = module: ({ pkgs, config, ...}@inputs:
    # let
    #   moduleEvaluated = module (inputs // { config = config.configurations; });
    # in {
    #   options.configurations = moduleEvaluated.options;
    #   config.configurations = moduleEvaluated.config;
    # });

    flake.wrapperHelpers.options.configurations = module: ({
        pkgs,
        config,
        ...
      } @ inputs: {
        options.configurations = mkOption {
          type = types.submodule {
            imports = [module];
            _module.args = inputs // {config = config.configurations;};
          };
          description = "The configurations of the program.";
          default = {};
        };
      });

    flake.wrapperHelpers.modules.theme = {pkgs, ...}: {
      options = {
        colors = mkOption {
          type = lib.types.submodule {
            options = lib.genAttrs base16Slots (
              slot:
                lib.mkOption {
                  type = hexColor;
                  example = "1a1b26";
                  description = "Base16 slot ${slot}.";
                }
            );
          };
          description = "A complete Base16 color scheme (base00–base0F as 6-digit hex strings with '#').";
          default = self.wrapperHelpers.theme.colors {inherit pkgs;};
        };
      };
    };

    flake.wrapperHelpers.theme.colors = {pkgs, ...}: let
      yamlToAttrs = file: builtins.fromJSON (builtins.readFile (pkgs.runCommand "yaml-to-json" {buildInputs = [pkgs.yq-go];} ''yq -o=json '.' ${file} > $out''));
      theme = yamlToAttrs "${pkgs.base16-schemes}/share/themes/tokyo-night-moon.yaml";
    in
      theme.palette;
  };
}
