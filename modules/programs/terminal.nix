{ self, lib, ... }: 

with lib;
let
  name = "terminal";
  terminal = "kitty";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({ ... }: {
    config = {
      preferences.programs.shell.enable = mkDefault true;
    };
  });

  flake.homeModules.programs = self.lib.mkHomeProgram name ({ ... }: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ ... }: {
    config = {
      preferences.programs.shell.enable = mkDefault true;
    };
  });

  flake.programs.${name} = self.lib.mkProgram name ({ pkgs, cfg, ... }: {
    configurations = [ self.definitions.programs.${name} ];
  });

  flake.wrappers.${name} = { ... }: {
    imports = [ self.wrapperModules.${terminal} ];
  };

  flake.definitions.programs.${name} = { pkgs, ... }: {
    options = {
      shell = mkOption {
        type = types.package;
        description = "The wrapped and configured shell package.";
        default = self.wrappers.shell.wrap { inherit pkgs; };
      };

      theme = let themePackage = pkgs.vimPlugins.tokyonight-nvim; in {
        package = mkOption {
          type = types.package;
          description = "The package of the theme, if any.";
          default = themePackage;
        };

        path = mkOption {
          type = types.str;
          description = "A path to the theme file, if any.";
          default = "${themePackage}/extras/kitty/tokyonight_moon.conf";
          # default = "${package}/extras/ghostty/tokyonight_moon";
        };
      };
    };
  };
}
