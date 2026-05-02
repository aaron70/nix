{lib, ...}:
with lib; {
  flake.nixosModules.configurations = {config, ...}: {
    config = mkIf config.information.hasBluetooth {
      services.blueman.enable = true;

      hardware.enableAllFirmware = true;
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Name = "${config.profile.user.username}-${config.information.hostname}";
            Experimental = true;
          };
        };
      };
    };
  };
}
