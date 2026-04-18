{ self, inputs, lib, ... }: 

with lib;
{
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      darwinModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
      };
    };
  };

  config.flake.darwinModules.configurations = { config, ... }: {
    imports = [ 
      self.nixosModules.profile
      self.nixosModules.programs
      self.nixosModules.features
    ];

    config = {
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      # TODO: Remove this line and uncomment the following
      system.stateVersion = "25.11";
      # system.stateVersion = 6;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowBroken = true;

      networking.networkmanager.enable = true;
      networking.hostName = config.profile.user.username;


      # TODO: Remove this one
      virtualisation.vmVariant = {
        virtualisation.graphics = true;
        virtualisation.qemu.options = [
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
        ];
      };
    };
  };
}
