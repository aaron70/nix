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

        # Improves the sound while the mic is on
        services.pipewire.wireplumber.extraConfig."52-bluez-codecs" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
          };
        };
      };
    };
  };
}
