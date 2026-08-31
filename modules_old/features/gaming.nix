{
  inputs,
  self,
  lib,
  ...
}:
with lib; let
  name = "gaming";
in {
  flake.darwinModules.features = self.lib.mkDarwinFeature name ({...}: {});

  flake.homeModules.features = self.lib.mkHomeFeature name ({...}: {});

  flake.nixosModules.features = self.lib.mkNixosFeature name ({
    config,
    cfg,
    ...
  }: {
    imports = [inputs.jovian.nixosModules.jovian];

    config = {
      jovian = {
        hardware.has.amd.gpu = cfg.configurations.gpu.isAMD;
        # devices.gpd-win-max-2.enable = true;
        steam = {
          enable = true;
          autoStart = false; # Start Steam in Big Picture mode at boot
          user = config.profile.user.username;
          # desktopSession = "gamescope-wayland";
        };
      };
    };
  });

  flake.features.${name} = self.lib.mkFeature name ({pkgs, ...}: {
    configurations = {
      gpu.isAMD = mkOption {
        type = types.bool;
        description = "Whether the gpu is AMD or not.";
        default = false;
      };
    };
    config = {
      programs = {
        steam.enable = true;
      };

      packages = with pkgs; [
        # Communication
        discord

        # Games
        ryubing # Nintendo Switch simulator
        pokemmo-installer # PokeMMO
        (heroic.override {extraPkgs = pkgs: [pkgs.gamescope];}) # Epic Games Launcher

        # Tools/Dependencies/Compatibility
        mangohud
        protonup-ng
      ];
    };
  });
}
