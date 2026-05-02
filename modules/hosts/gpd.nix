{
  inputs,
  self,
  ...
}: let
  host = "gpd";
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.${host}];
  };

  flake.nixosModules.${host} = {...}: {
    imports = [
      self.nixosModules.configurations
      self.nixosModules."${host}-hardware"
    ];

    config = {
      information = {
        hostname = "gpd";
        isLaptop = true;
        hasBluetooth = true;
        hasBattery = true;
      };

      preferences = {
        profile = "personal";

        features = {
          gaming = {
            enable = true;
            configurations.gpu.isAMD = true;
          };
        };

        programs = {
          desktop = {
            enable = true;
            configurations = {
              monitors = rec {
                HDMI-A-1 = {
                  enabled = true;
                  primary = true;
                  x = 0;
                  y = 0;
                  width = 1920;
                  height = 1080;
                  refreshRate = 143.981;
                };

                DP-1 = rec {
                  enabled = true;
                  primary = false;
                  x = -width;
                  y = 0;
                  width = 2560;
                  height = 1440;
                  refreshRate = 74.932;
                };

                eDP-1 = {
                  enabled = true;
                  primary = false;
                  x = DP-1.x;
                  y = 800;
                  width = 2560;
                  height = 1600;
                  refreshRate = 60.009;
                  scale = 2.0;
                };
              };
            };
          };
        };
      };
    };
  };

  flake.nixosModules."${host}-hardware" = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/a382f749-eb68-4cd7-b3ac-4e96d34eb719";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/E84A-8A5C";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    fileSystems."/home/aaronv/shared-home" = {
      device = "/dev/disk/by-uuid/6AB20C7DB20C504D";
      fsType = "ntfs";
      options = ["users" "nofail" "exec" "rw" "uid=1000" "gid=100"];
    };

    swapDevices = [];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp195s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
