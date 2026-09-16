{inputs, ...}: {
  anvil.programs.steam = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [
        (final: prev: {
          xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: rec {
            version = "0.8.1";
            src = final.fetchFromGitHub {
              owner = "Supreeeme";
              repo = "xwayland-satellite";
              rev = "v${version}";
              hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
            };
            cargoDeps = final.rustPlatform.importCargoLock {
              lockFile = "${src}/Cargo.lock";
            };
          });
        })
      ];

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
      };

      programs = {
        gamemode.enable = true;
        gamescope.enable = true;
        steam = {
          package = pkgs.steam.override {
            extraProfile = ''
              unset TZ
              # Allows Monado/WiVRn to be used
              export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
            '';
          };
          enable = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
          extraPackages = with pkgs; [
            SDL2
            gamescope
            er-patcher
          ];
          protontricks.enable = true;
        };
      };
    };
  };
}
