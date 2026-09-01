{ lib, ... }:
with lib;
{
  flake.declarations.shell = {...}: {
    options = {
      activationScripts = mkOption {
        type = types.listOf types.str;
        description = "A list of activations scripts to source on the shell configuration startup";
        default = [];
      };

      packages = mkOption {
        type = types.listOf types.package;
        description = "A list of packages to install with the shell";
        default = [];
      };

      envVariables = mkOption {
        type = types.attrsOf types.str;
        description = "An attrset with env variables";
        default = {};
      };

      shellAliases = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        description = "An attrset with shell aliases";
        default = {};
      };

      prompt = {
        name = mkOption {
          type = types.str;
          description = "The name of the shell prompt";
        };
        getPackage = mkOption {
          type = types.functionTo types.package;
          description = "The package of the shell prompt";
        };
        activationScript = mkOption {
          type = types.str;
          description = "The activation script to source the prompt on the shell configuration startup";
        };
      };

      multiplexer = {
        name = mkOption {
          type = types.str;
          description = "The name of the terminal multiplexer prompt";
        };
        getPackage = mkOption {
          type = types.functionTo types.package;
          description = "The package of the shell multiplexer";
        };
        activationScript = mkOption {
          type = types.str;
          description = "The activation script to source the multiplexer on the shell configuration startup";
        };
      };
    };
  };
}
