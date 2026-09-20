{inputs, ...}: {
  anvil.programs.steam = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [
        (final: prev: {
          xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
            version = "0.8.1";
            src = inputs.xwayland-satellite-stable;
            cargoDeps = final.rustPlatform.importCargoLock {
              lockFile = "${inputs.xwayland-satellite-stable}/Cargo.lock";
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
          # package = pkgs.steam.override {
          #   extraProfile = ''
          #     unset TZ
          #     # Allows Monado/WiVRn to be used
          #     export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
          #   '';
          # };
          enable = true;
          remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
          dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
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
