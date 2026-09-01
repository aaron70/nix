{self, ...}: {
  anvil.hosts.pc = {
    systems.nixos = "x86_64-linux";
    users = { host, ... }: [host.metadata.mainUser];
    features = [
      "configurations"
    ];
    programs = [];
    metadata = rec {
      mainUser = "aaronv";
      configurationLimit = 3;
      nixPath = "/home/${mainUser}/nix";
    };
    nixos = {...}: {
      imports = [ self.nixosModules."pc-hardware" ];
    };
  };

  flake.nixosModules."pc-hardware" = {
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
      device = "/dev/disk/by-uuid/bc1505b2-bf23-418f-853e-d7a1114cbf5b";
      fsType = "ext4";
    };

    # Mount for windows partition
    fileSystems."/home/aaronv/windows" = {
      device = "/dev/disk/by-uuid/66B0958CB09562FB";
      fsType = "ntfs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F419-7943";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
