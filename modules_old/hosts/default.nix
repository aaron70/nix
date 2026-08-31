{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      hosts = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config = {
    flake.nixosModules.configurations = {...}: {
      imports = [self.hosts.module];
    };

    flake.darwinModules.configurations = {...}: {
      imports = [self.hosts.module];
    };

    flake.hosts.module = {config, ...}: {
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
  };
}
