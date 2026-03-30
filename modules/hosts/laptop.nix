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
        isLaptop = true;
        hasBluetooth = true;
        hasBattery = true;
      };

      preferences = {
        profile = "personal";

        desktop.enable = true;
      };
    };
  };

  flake.nixosModules."${host}-hardware" = { config, lib, pkgs, modulesPath, ... }: {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];
  
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
  
    fileSystems."/" =
      { device = "/dev/disk/by-uuid/d7411d9a-9f9a-4d9f-9579-6b16800ad339";
        fsType = "ext4";
      };
  
    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/46BF-A942";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };
  
    swapDevices = [ ];
  
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;
  
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
