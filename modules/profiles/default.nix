{ inputs, self, lib, ... }: 

with lib;
{

  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      profile = inputs.nixpkgs.lib.mkOption {
        default = {};
      };

      profiles.generic = inputs.nixpkgs.lib.mkOption {
        default = {};
      };

      profiles.nixos = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = {
    flake.nixosModules.profile = { ... }: {
      imports = [ 
        self.profile.module
      ] ++ builtins.attrValues self.profiles.nixos;
    };

    flake.profile.module = { ... }: {
      imports = builtins.attrValues self.profiles.generic;

      options.preferences = {
        profile = mkOption {
          type = types.str;
          description = "The name of the profile to use";
        };
      };

      options.profile = {
        user = {
          username = mkOption {
            type = types.str;
            description = "The username of the user";
          };
          fullname = mkOption {
            type = types.str;
            description = "The full name of the user";
          };
          email = mkOption {
            type = types.str;
            description = "The email address of the user";
          };
        };
      };
    };  
  };
}
