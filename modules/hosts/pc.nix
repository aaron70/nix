{
  inputs,
  self,
  lib,
  ...
}: let
  host = "pc";
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.${host}];
  };

  flake.nixosModules.${host} = {pkgs, ...}: {
    imports = [
      self.nixosModules.configurations
      self.nixosModules."${host}-hardware"
    ];

    config = {
      information = {
        hostname = "pc";
        isLaptop = false;
        hasBluetooth = true;
        hasBattery = false;
      };

      preferences = {
        profile = "personal";

        features = {
          gaming.enable = true;
        };

        programs = {
          desktop = {
            enable = true;
            configurations = {
              monitors = {
                DP-1 = {
                  enabled = true;
                  primary = true;
                  x = 0;
                  y = 0;
                  width = 1920;
                  height = 1080;
                  refreshRate = 143.981;
                };

                HDMI-A-1 = rec {
                  enabled = true;
                  primary = false;
                  x = -width;
                  y = 0;
                  width = 2560;
                  height = 1440;
                  refreshRate = 74.932;
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

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/c64dea84-1962-43bc-9866-bc5b451c0314";
      fsType = "ext4";
    };

    # Mount for windows partition
    fileSystems."/home/aaronv/windows" = {
      device = "/dev/disk/by-uuid/66B0958CB09562FB";
      fsType = "ntfs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F494-F2B3";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
