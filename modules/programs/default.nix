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

  config = rec {
    flake.lib.mkDarwinProgram = flake.lib.mkNixosProgram;
    flake.lib.mkNixosProgram = name: module: ({ pkgs, config, ... }@inputs: 
    let
      cfg = config.preferences.programs.${name};
      moduleEvaluated = (module (inputs // { inherit cfg; }));
    in {
      imports = ([
        self.programs.${name}
      ] ++ (moduleEvaluated.imports or []));

      options = (moduleEvaluated.options or {});

      config = mkIf cfg.enable ({
        environment.systemPackages = mkIf (cfg.package != null) [ cfg.package ];
      } // (moduleEvaluated.config or {}));
    });

    flake.lib.mkHomeProgram = name: module: ({ pkgs, config, ... }@inputs: 
    let
      cfg = config.preferences.programs.${name};
      moduleEvaluated = (module (inputs // { inherit cfg; }));
    in {
      imports = ([
        self.programs.${name}
      ] ++ (moduleEvaluated.imports or []));

      options = (moduleEvaluated.options or {});

      config = mkIf cfg.enable ({
        home.packages = mkIf (cfg.package != null) [ cfg.package ];
      } // (moduleEvaluated.config or {}));
    });

    flake.lib.mkProgram = name: module: ({ pkgs, config, ... }@inputs: 
    let
      cfg = config.preferences.programs.${name};
      moduleEvaluated = (module (inputs // { inherit cfg; }));
    in {
      imports = moduleEvaluated.imports or [];

      options.preferences.programs.${name} = ({
        enable = mkEnableOption "Whether to enable the ${name} program.";
        package = mkOption {
          type = types.nullOr types.package;
          description = "The package of the program, it could be a wrapper.";
          default = self.wrappers.${name}.wrap {
            inherit pkgs;
            configurations = cfg.configurations;
          };
        };
        configurations = mkOption {
          type = types.submodule {
            imports = moduleEvaluated.configurations or [];
            _module.args = (inputs // { 
              config = cfg.configurations;
            });
          };
          description = "The configurations of the program.";
          default = {};
        };
      } // (moduleEvaluated.options or {}));

      config = mkIf cfg.enable {
        preferences.programs.${name} = moduleEvaluated.config or {};
      };
    });

    flake.lib.mkConfigurationsOption = configurations: ({ pkgs, ... }@inputs: {
      options = {
        configurations = mkOption {
          type = types.submodule { 
            imports = configurations; 
            _module.args = inputs;
          };
          description = "The configurations of the program.";
          default = {};
        };
      };
    });
  };
}
