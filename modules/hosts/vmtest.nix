{ inputs, self, ... }: 

{
  flake.nixosConfigurations.vmtest = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.vmtest ];
  };

  flake.nixosModules.vmtest = { modulesPath, ... }: {
    imports = [ 
      self.nixosModules.configurations 
      "${modulesPath}/virtualisation/qemu-vm.nix" 
    ];

    users.users.vmtest = {
      isNormalUser = true;
      initialPassword = "test";
      group = "vmtest";
    };
    users.groups.vmtest = {};

    preferences = {
      profile = "vmtest";

      desktop.enable = true;
    };


    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    virtualisation.graphics = true;
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];

    environment.systemPackages = [
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
