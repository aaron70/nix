{self, ...}: {
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
    nixos = {...}: {
      imports = [self.nixosModules."laptop-hardware"];
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
