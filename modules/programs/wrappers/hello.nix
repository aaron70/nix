{ self, lib, ... }: 

with lib;
let 
  name = "hello";
in {
  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ ... }: {});

  flake.programs.${name} = self.lib.mkProgram name ({ pkgs, cfg, ... }: {
    configurations = [ self.definitions.${name} ];
    config = {
      package = self.wrappers.${name}.wrap {
        inherit pkgs;
        configurations = cfg.configurations;
      };
    };
  });

  flake.wrappers.${name} = { wlib, config, pkgs, ... }@inputs: {
    imports = [ 
      wlib.modules.default 
      (self.lib.mkConfigurationsOption [ self.definitions.${name} ])
    ];

    config = {
      package = pkgs.hello;
      flags."-g" = config.configurations.greeting;
    };
  };

  flake.definitions.${name} = { pkgs, config, ... }: {
    options = {
      greeting = mkOption {
        type = types.str;
        default = "Default greeting ${config.package}";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.hello;
      };
    };

    config = {
      package = pkgs.alacritty;
    };
  };
}
