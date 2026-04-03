{ self, lib, ... }: 

with lib;
let 
  name = "hello";
in {

  flake.programs.${name} = self.lib.mkProgram name ({ pkgs, cfg, ... }@inputs: let
    definition = self.definitions.programs.${name} inputs;
  in {
    configurations = [
      self.definitions.programs.${name}
    ];
    # options = definition.options;
    config = {
      package = self.wrappers.${name}.wrap {
        inherit pkgs;
        configurations = cfg.configurations;
      };
    };
  }); 

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ ... }: {});

  flake.definitions.programs.${name} = { pkgs, config, ... }: {
    options = {
      greeting = mkOption {
        type = types.str;
        description = "The Ghostty configuration file's contents.";
        # default = "Hello program!";
      };

      other = mkOption {
        type = types.str;
        default = "loco";
      };
    };

    config = {
      greeting = mkDefault "Hello ${config.other} ${getExe pkgs.hello}!";
    };
  };

  flake.wrappers.${name} = { config, wlib, pkgs, ... }: {
    imports = [
      (self.wrapperHelpers.options.configurations self.definitions.programs.${name})
      wlib.modules.default 
    ];

    config = {
      package = pkgs.hello;
      # flagSeparator="=";
      # flags."-g" = mkIf (cfg.configurations.greeting != "") cfg.configurations.greeting;
      flags."-g" = config.configurations.greeting;
    };
  };
}
