{
  inputs,
  lib,
  ...
}:
with lib; {
  anvil.features.jovian = {
    features = [
      "gaming"
    ];
    nixos = {host, ...}: {
      imports = [inputs.jovian.nixosModules.jovian];

      jovian = {
        hardware.has.amd.gpu = host.metadata.gpu.isAMD or false;
        devices.gpd-win-max-2.enable = host.metadata.isGPD or false;
        steam = {
          enable = true;
          autoStart = false; # Start Steam in Big Picture mode at boot
          user = mkIf (user != null) user.name;
          # desktopSession = "gamescope-wayland";
        };
      };
    };
  };
}
