{...}: {
  anvil.features.nvidia = {
    features = [
      "graphics"
    ];
    nixos = {config, ...}: {
      services.xserver.videoDrivers = ["nvidia"];
      hardware = {
        nvidia = {
          # Enable modesetting for Wayland compositors
          modesetting.enable = true;
          # Use the open source version of the kernel module (for driver 515.43.04+)
          open = true;
          # Enable the Nvidia settings menu
          nvidiaSettings = true;
          # Select the appropriate driver version for your specific GPU
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          powerManagement.enable = true;
        };
      };
    };
  };
}
