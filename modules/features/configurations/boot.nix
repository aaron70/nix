{lib, ...}:
with lib; {
  anvil.features.boot = {
    nixos = {
      host,
      pkgs,
      config,
      ...
    }: {
      config = {
        assertions = [
          {
            assertion = (host.metadata.configurationLimit or null) != null;
            message = "boot: host '${host.name or "?"}' must set `metadata.configurationLimit`.";
          }
        ];

        boot = {
          # Quiet boot
          consoleLogLevel = 0;

          kernelParams = [
            "quiet"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
          ];
          kernelModules = ["ddcci-backlight"];
          kernelPackages = pkgs.linuxPackages_latest;
          extraModulePackages = with config.boot.kernelPackages; [ddcci-driver];

          loader.systemd-boot = {
            enable = mkDefault true;
            configurationLimit = mkDefault host.metadata.configurationLimit;
          };
          loader.efi.canTouchEfiVariables = true;
          loader.timeout = 30;

          plymouth.enable = true;
        };
      };
    };
  };
}
