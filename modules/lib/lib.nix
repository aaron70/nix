{ inputs, lib, ... }: 

with lib;
{
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      lib = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config.flake.lib = {
    mkProfile = profile: preferences: ({ config, pkgs, ... }: {
      config = mkIf (config.preferences.profile == profile) (preferences { inherit config pkgs; });
    });
  };
}
