{ inputs, self, lib, ... }: 

with lib;
{
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      programs = inputs.nixpkgs.lib.mkOption {
        default = {};
      };

      definitions.programs = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = {
    flake.lib.mkNixosProgram = name: module: ({ pkgs, config, ... }@inputs: 
    let
      cfg = config.preferences.programs.${name};
      moduleEvaluated = (module (inputs // { inherit cfg; }));
    in {
      imports = ([
        self.programs.${name}
      ] ++ (if moduleEvaluated ? imports then moduleEvaluated.imports else []));

      options = (if moduleEvaluated ? options then moduleEvaluated.options else {});

      config = mkIf cfg.enable ({
        environment.systemPackages = mkIf (cfg.package != null) [ cfg.package ];
      } // (if moduleEvaluated ? config then moduleEvaluated.config else {}));
    });

    flake.lib.mkProgram = name: module: ({ pkgs, config, ... }@inputs: 
    let
      cfg = config.preferences.programs.${name};
      moduleEvaluated = (module (inputs // { inherit cfg; }));
    in {
      imports = if moduleEvaluated ? imports then moduleEvaluated.imports else [];

      options.preferences.programs.${name} = ({
        enable = mkEnableOption "Whether to enable the ${name} program.";
        package = mkOption {
          type = types.nullOr types.package;
          description = "The package of the program, it could be a wrapper.";
          default = null;
        };
        configurations = mkOption {
          type = types.submodule {
            imports = moduleEvaluated.configurations;
            _module.args = (inputs // { 
              config = cfg.configurations;
            });
          };
          description = "The configurations of the program.";
          default = {};
        };
      } // (if moduleEvaluated ? options then moduleEvaluated.options else {}));

      config = mkIf cfg.enable {
        preferences.programs.${name} = moduleEvaluated.config;
      };
    });
  };
}
