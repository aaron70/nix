{
  self,
  lib,
  ...
}:
with lib; let
  name = "steam";
in {
  flake.homeModules.programs = self.lib.mkHomeProgram name ({...}: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({pkgs, ...}: {
    config = {
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
  });

  flake.programs.${name} = self.lib.mkProgram name ({...}: {
    configurations = [self.definitions.programs.terminal];
    config = {
      package = null;
    };
  });
}
