{...}: {
  anvil.features.usb = {
    nixos = {...}: {
      services.udisks2.enable = true;
    };
    home = {pkgs, ...}: {
      services.udiskie.enable = true;
      home.packages = with pkgs; [ hello ];
    };
  };
}
