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
        i2c.enable = true;
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
          powerManagement.enable = true;
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
        variant = "";
        options = "compose:ralt";
      };
      environment.variables = {
        GTK_IM_MODULE = "xim";
        QT_IM_MODULE = "xim";
      };

      security.polkit.enable = true;
      security.polkit.enablePkexecWrapper = true;
      # environment.systemPackages = [pkgs.polkit_gnome]; NOTE: Using the built-in noctalia polkit-agent
      services.fprintd.enable = true;

      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;



      services.logind.settings.Login = {
        HandleLidSwitch = "suspend"; # Lid Closed
        HandleLidSwitchExternalPower = "suspend"; # Lid Closed while connected to power
        HandleLidSwitchDocked = "ignore"; # Lic Closed while connected to another screens
      };
      # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "suspend-then-hibernate", "lock"

      # Faster rebuilding
      documentation = {
        enable = true;
        doc.enable = false;
        man.enable = true;
        dev.enable = false;
        info.enable = false;
        nixos.enable = false;
      };

      system.stateVersion = config.preferences.stateVersion;
    };
  };
}
