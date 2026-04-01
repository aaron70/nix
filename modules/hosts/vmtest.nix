{ inputs, self, ... }: 

{
  flake.nixosConfigurations.vmtest = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.vmtest ];
  };

  flake.nixosModules.vmtest = { config, modulesPath, ... }: {
    imports = [ 
      self.nixosModules.configurations 
      # "${modulesPath}/virtualisation/qemu-vm.nix" 
    ];

    config = {
      information = {
        hostname = "vmtest";
        isLaptop = false;
        hasBluetooth = true;
        hasBattery = false;
      };

      preferences = {
        profile = "vmtest";

        desktop.enable = true;
      };

      nixpkgs.hostPlatform = "x86_64-linux";
    };

      # virtualisation.vmVariant = {
      #   # following configuration is added only when building VM with build-vm
      #   users.users.${config.profile.user.username} = {
      #     isNormalUser = true;
      #     # description = config.profile.user.fullname;
      #     # extraGroups = [ "networkmanager" "wheel" "audio" ];
      #     group = config.profile.user.username;
      #     initialPassword = "test";
      #   };
      #   users.users.root.initialPassword = "root";
      # };

    # users.users.${config.profile.user.username} = {
    #   isNormalUser = true;
    #   initialPassword = "test";
    #   group = config.profile.user.username;
    # };
    # users.groups.${config.profile.user.username} = {};

    # virtualisation.graphics = true;
    # virtualisation.qemu.options = [
    #   "-device virtio-vga-gl"
    #   "-display gtk,gl=on"
    # ];
  };
}
