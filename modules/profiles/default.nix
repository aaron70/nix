{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
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

      profiles.home = inputs.nixpkgs.lib.mkOption {
        default = {};
      };

      profiles.darwin = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = rec {
    flake.lib.mkHomeProfile = flake.lib.mkNixosProfile;
    flake.lib.mkDarwinProfile = flake.lib.mkNixosProfile;

    flake.lib.mkNixosProfile = profile: preferences: ({
        config,
        pkgs,
        ...
      } @ inputs: {
        config = mkIf (config.preferences.profile == profile) ({
            preferences = {
              programs = config.profile.programs;
              features = config.profile.features;
            };
          }
          // preferences inputs);
      });

    flake.lib.mkProfile = profile: preferences: ({
      config,
      pkgs,
      ...
    }: {
      config = mkIf (config.preferences.profile == profile) (preferences {inherit config pkgs;});
    });

    flake.nixosModules.profile = {...}: {
      imports =
        [
          self.profile.module
        ]
        ++ builtins.attrValues self.profiles.nixos;
    };

    flake.homeModules.profile = {...}: {
      imports =
        [
          self.profile.module
        ]
        ++ builtins.attrValues self.profiles.home;
    };

    flake.darwinModules.profile = {...}: {
      imports =
        [
          self.profile.module
        ]
        ++ builtins.attrValues self.profiles.darwin;
    };

    flake.profile.module = {...}: {
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

        programs = mkOption {
          type = types.attrs;
          description = "The programs and their configurations to enable with this profile.";
          default = {};
        };

        features = mkOption {
          type = types.attrs;
          description = "The features and their configurations to enable with this profile.";
          default = {};
        };
      };
    };
  };
}
