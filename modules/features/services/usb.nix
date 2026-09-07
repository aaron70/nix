{...}: {
  anvil.features.usb = {
    nixos = {...}: {
      services.udisks2.enable = true;
    };
    home = {...}: {
      services.udiskie.enable = true;
    };
  };
}
