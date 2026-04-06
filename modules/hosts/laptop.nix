{ inputs, self, ... }: 

let
  host = "laptop";
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.${host} ];
  };

  flake.nixosModules.${host} = { ... }: {
    imports = [
      self.nixosModules.configurations 
      self.nixosModules."${host}-hardware"
    ];

    config = {
      information = {
        hostname = "laptop";
        isLaptop = true;
        hasBluetooth = true;
        hasBattery = true;
      };

      preferences = {
        profile = "personal";

        programs = {
          desktop = {
            enable = true;
            configurations = {
              modKey = "alt";
              modKeyAlt = "super";
              monitors = rec {
                DP-3 = {
                  enabled = true; primary = true;
                  x = 0; y = 0;
                  width = 1920; height = 1080;
                  refreshRate = 143.981;
                };

                HDMI-A-2 = rec {
                  enabled = true; primary = false;
                  x = -width; y = 0;
                  width = 2560; height = 1440;
                  refreshRate = 74.932;
                };

                eDP-1 = rec {
                  enabled = true; primary = false;
                  x = -HDMI-A-2.x; y = -height;
                  width = 1920; height = 1080;
                  refreshRate = 59.977;
                };
              };
            };
          };
        };
      };
    };
  };

  flake.nixosModules."${host}-hardware" = { config, lib, pkgs, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
  
    fileSystems."/" =
      { device = "/dev/disk/by-uuid/f60eed8e-8feb-4c44-8c77-7cfcf9aa41ba";
        fsType = "ext4";
      };
  
    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/46BF-A942";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };
  
    swapDevices = [ ];
  
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
