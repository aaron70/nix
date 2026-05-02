{lib, ...}:
with lib; {
  flake.nixosModules.configurations = {
    pkgs,
    config,
    ...
  }: {
    config = {
      boot = {
        # Quiet boot
        consoleLogLevel = 0;
        initrd.verbose = false;

        kernelParams = [
          "quiet"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
        kernelPackages = pkgs.linuxPackages_latest;

        loader.systemd-boot = {
          enable = mkDefault true;
          configurationLimit = mkDefault config.preferences.boot.configurationLimit;
        };
        loader.efi.canTouchEfiVariables = true;
        loader.timeout = 30;

        plymouth.enable = true;
      };
    };
  };
}
