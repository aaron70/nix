{...}: {
  anvil.features.bluetooth = {
    nixos = {
      host,
      user,
      ...
    }: {
      config = {
        services.blueman.enable = true;

        hardware.enableAllFirmware = true;
        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings = {
            General = {
              Name =
                if user != null
                then "${user.name}-${host.name}"
                else "${host.metadata.mainUser}-${host.name}";
              Experimental = true;
            };
          };
        };
      };
    };
  };
}
