{...}: {
  anvil.features.graphics = {
    nixos = {config, ...}: {
      hardware = {
        i2c.enable = true;
        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };
    };
  };
}
