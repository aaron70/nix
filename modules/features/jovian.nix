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

      # Features are evaluated at host level (user = null), so read the user from `host`.
      warnings = optional (!(host.metadata ? gpu)) "jovian: host '${host.name or "?"}' has no metadata.gpu; hardware.has.amd.gpu defaults to false.";

      # Jovian ships its own cap_sys_nice gamescope wrapper;
      # nixpkgs' gamescope wrapper would conflict on security.wrappers.gamescope.source
      programs.gamescope.capSysNice = lib.mkForce false;

      jovian = {
        hardware.has.amd.gpu = host.metadata.gpu.isAMD or false;
        steam = {
          enable = true;
          autoStart = false; # Start Steam in Big Picture mode at boot
          user = host.metadata.mainUser;
          # desktopSession = "gamescope-wayland";
        };
      };
    };
  };
}
