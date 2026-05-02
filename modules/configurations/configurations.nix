{
  self,
  lib,
  ...
}:
with lib; {
  flake.nixosModules.configurations = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.profile
      self.nixosModules.programs
      self.nixosModules.features
    ];

    config = {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowBroken = true;
      programs.nix-ld.enable = true;

      services.xserver.videoDrivers = ["nvidia"];
      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };
        nvidia = {
          # Enable modesetting for Wayland compositors
          modesetting.enable = true;
          # Use the open source version of the kernel module (for driver 515.43.04+)
          open = true;
          # Enable the Nvidia settings menu
          nvidiaSettings = true;
          # Select the appropriate driver version for your specific GPU
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
      };

      virtualisation.vmVariant = {
        virtualisation.graphics = true;
        virtualisation.qemu.options = [
          "-device virtio-vga-gl"
          "-display gtk,gl=on"
        ];
      };

      services.printing.enable = true;

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # To use JACK applications
        # jack.enable = true;
      };

      networking.networkmanager.enable = true;
      networking.hostName = config.profile.user.username;
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      time.timeZone = mkDefault "America/Costa_Rica";

      # Select internationalisation properties.
      i18n.defaultLocale = mkDefault "en_US.UTF-8";
      i18n.extraLocaleSettings = mkDefault {
        LC_ADDRESS = "es_CR.UTF-8";
        LC_IDENTIFICATION = "es_CR.UTF-8";
        LC_MEASUREMENT = "es_CR.UTF-8";
        LC_MONETARY = "es_CR.UTF-8";
        LC_NAME = "es_CR.UTF-8";
        LC_NUMERIC = "es_CR.UTF-8";
        LC_PAPER = "es_CR.UTF-8";
        LC_TELEPHONE = "es_CR.UTF-8";
        LC_TIME = "es_CR.UTF-8";
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "altgr-intl";
      };

      system.stateVersion = config.preferences.stateVersion;
    };
  };
}
