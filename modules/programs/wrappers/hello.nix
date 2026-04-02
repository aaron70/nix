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

  flake.definitions.programs.${name} = { ... }: {
    options = {
      greeting = mkOption {
        type = types.str;
        description = "The Ghostty configuration file's contents.";
        # default = "Hello program!";
      };
    };

    config = {
      greeting = mkDefault "Hello from configurations!";
    };
  };

  flake.wrappers.${name} = { config, wlib, pkgs, ... }: {
    imports = [
      wlib.modules.default 
    ];

    options.configurations = mkOption {
      type = types.submodule self.definitions.programs.${name};
      description = "The program's configurations";
    };

    config = {
      package = pkgs.hello;
      # flagSeparator="=";
      # flags."-g" = mkIf (cfg.configurations.greeting != "") cfg.configurations.greeting;
      flags."-g" = config.configurations.greeting;
    };
  };
}
