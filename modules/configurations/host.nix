{ lib, ... }: 

with lib;
{

  flake.nixosModules.host = { config, ... }: {
    options.preferences = {
      stateVersion = mkOption {
        type = types.str;
        description = "The state version to be used on `system.stateVersion` and `home.stateVersion` options";
        default = "25.11";
      };

      boot = {
        configurationLimit = mkOption {
          type = types.number;
          description = "The limit of generations to show.";
          default = 3;
        };
      };

      profile = mkOption {
        type = types.str;
        description = "The name of the profile to use";
      };
    };

    options.information = {
      isLaptop = mkEnableOption "Whether the host is a laptop.";
      hasBluetooth = mkEnableOption "Whether the host has Bluetooth.";
      hasBattery = mkEnableOption "Whether the host has Bluetooth.";
      hostname = mkOption {
        type = types.str;
        description = "The name of the configuration's host.";
      };
    };

    config = {
      information = {
        isLaptop = mkDefault false;
        hasBluetooth = mkDefault true;
        hasBattery = mkDefault config.information.isLaptop;
      };
    };
  };

}
