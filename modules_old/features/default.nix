{
  self,
  inputs,
  lib,
  ...
}:
with lib; {
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      features = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = rec {
    flake.lib.mkHomeFeature = name: module: ({
        pkgs,
        config,
        ...
      } @ inputs: let
        cfg = config.preferences.features.${name};
        moduleEvaluated = module (inputs // {inherit cfg;});
      in {
        imports =
          [
            self.features.${name}
          ]
          ++ (moduleEvaluated.imports or []);

        options = moduleEvaluated.options or {};

        config = mkIf cfg.enable ({
            preferences.programs = cfg.programs;
            home.packages = cfg.packages;
          }
          // (moduleEvaluated.config or {}));
      });

    flake.lib.mkDarwinFeature = flake.lib.mkNixosFeature;
    flake.lib.mkNixosFeature = name: module: ({
        pkgs,
        config,
        ...
      } @ inputs: let
        cfg = config.preferences.features.${name};
        moduleEvaluated = module (inputs // {inherit cfg;});
      in {
        imports =
          [
            self.features.${name}
          ]
          ++ (moduleEvaluated.imports or []);

        options = moduleEvaluated.options or {};

        config = mkIf cfg.enable ({
            preferences.programs = cfg.programs;
            environment.systemPackages = cfg.packages;
          }
          // (moduleEvaluated.config or {}));
      });

    flake.lib.mkFeature = name: module: ({
        pkgs,
        config,
        ...
      } @ inputs: let
        cfg = config.preferences.features.${name};
        moduleEvaluated = module (inputs // {inherit cfg;});
      in {
        imports = moduleEvaluated.imports or [];

        options.preferences.features.${name} = {
          enable = mkEnableOption "Whether to enable the ${name} feature.";
          programs = mkOption {
            type = types.attrs;
            description = "The programs and their configurations to enable with this feature.";
            default = {};
          };

          packages = mkOption {
            type = types.listOf types.package;
            description = "The list of packages to install with this feature.";
            default = [];
          };

          configurations = moduleEvaluated.configurations or {};
        };

        config = mkIf cfg.enable {
          preferences.features.${name} = moduleEvaluated.config or {};
        };
      });
  };
}
