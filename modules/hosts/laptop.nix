{
  self,
  lib,
  ...
}:
with lib; {
  anvil.hosts.laptop = {
    systems.nixos = "x86_64-linux";
    users = {host, ...}: [host.metadata.mainUser];
    features = [
      "configurations"
    ];
    programs = [];
    metadata = rec {
      mainUser = "aaronv";
      configurationLimit = 3;
      nixPath = "/home/${mainUser}/nix";
    };
    nixos = {pkgs, ...}: {
      imports = [self.nixosModules."laptop-hardware"];
      anvil.desktop.preferences.modKey = "alt";
      anvil.desktop.preferences.modKeyAlt = "super";
      anvil.desktop.preferences.monitors = rec {
        DP-1 = {
          enabled = true;
          primary = true;
          x = 0;
          y = 0;
          width = 1920;
          height = 1080;
          refreshRate = 143.981;
        };

        HDMI-A-2 = rec {
          enabled = true;
          primary = false;
          x = -width;
          y = 0;
          width = 2560;
          height = 1440;
          refreshRate = 74.932;
        };

        eDP-1 = rec {
          enabled = true;
          primary = false;
          x = -HDMI-A-2.x;
          y = -height;
          width = 1920;
          height = 1080;
          refreshRate = 59.977;
        };
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          # intel-media-driver # for newer Intel iGPUs (Broadwell+)
          intel-vaapi-driver # for older Intel iGPUs
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };
    };
  };

  flake.nixosModules."laptop-hardware" = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/f60eed8e-8feb-4c44-8c77-7cfcf9aa41ba";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/46BF-A942";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
