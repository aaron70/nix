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
          kernelModules = ["ddcci-backlight"];
          # TODO: (revert) kernel 7.2 removed strncpy(), breaking ddcci-driver.
          # Tracked upstream: https://github.com/NixOS/nixpkgs/issues/554041
          # Fix PR (open, unmerged): https://github.com/NixOS/nixpkgs/pull/556080
          # Once merged, drop this `extend` override and use:
          #   kernelPackages = pkgs.linuxPackages_latest;
          kernelPackages = pkgs.linuxPackages_latest.extend (final: prev: {
            ddcci-driver = prev.ddcci-driver.overrideAttrs (oldAttrs: {
              patches = [
                (pkgs.fetchpatch {
                  name = "ddcci-sysfs-emit-kernel-7.2.patch";
                  url = "https://gitlab.com/liquidnya/ddcci-driver-linux/-/commit/9510aa4aebf32678884f55ae251e54012a354ed1.patch";
                  hash = "sha256-s12ers7nPFaHOB+8/S8t3dtdoR6slukkfNPdghgftNs=";
                })
              ] ++ (oldAttrs.patches or []);
            });
          });
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
