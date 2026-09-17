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
    nixos = {
      host,
      user,
      ...
    }: {
      imports = [inputs.jovian.nixosModules.jovian];

      jovian = {
        hardware.has.amd.gpu = host.metadata.gpu.isAMD or false;
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
