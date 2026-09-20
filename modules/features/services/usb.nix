{lib, ...}:
with lib; {
  anvil.features.usb = {
    nixos = {...}: {
      services.udisks2.enable = true;
    };
    home = {pkgs, ...}: {
      services.udiskie.enable = mkIf pkgs.stdenv.hostPlatform.isLinux true;
    };
  };
}
