{ self, lib, ... }: 

with lib;
{
  flake.nixosModules.configurations = { config, pkgs, ... }: {
    imports = [ 
      self.nixosModules.profile
    ];

    options.preferences = {
      stateVersion = mkOption {
        type = types.str;
        description = "The state version to be used on `system.stateVersion` and `home.stateVersion` options";
        default = "25.11";
      };
    };

    config = {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowBroken = true;

        # TODO: Remove this 
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        # To disable installing GNOME's suite of applications
        # and only be left with GNOME shell.
        services.gnome.core-apps.enable = false;
        services.gnome.core-developer-tools.enable = false;
        services.gnome.games.enable = false;
        environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
        environment.systemPackages = with pkgs; [ kitty ];
               
      services.xserver.videoDrivers = [ "nvidia" ];
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

      services.printing.enable = true;

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
      networking.hostName = "test"; #TODO: Change this for the profile username
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
