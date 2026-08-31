{
  inputs,
  self,
  ...
}: let
  host = "gpd";
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.${host}];
  };

  flake.nixosModules.${host} = {...}: {
    imports = [
      self.nixosModules.configurations
      self.nixosModules."${host}-hardware"
    ];

    config = {
      # Unccomment to disable fingerprint for sudo and polkit
      # security.pam.services = {
      #   sudo.fprintAuth = false;
      #   polkit-1.fprintAuth = false;
      # };

      information = {
        hostname = "gpd";
        isLaptop = true;
        hasBluetooth = true;
        hasBattery = true;
      };

      preferences = {
        profile = "personal";

        features = {
          gaming = {
            enable = true;
            configurations.gpu.isAMD = true;
          };
        };

        programs = {
          desktop = {
            enable = true;
            configurations = {
              monitors = rec {
                HDMI-A-1 = {
                  enabled = true;
                  primary = true;
                  x = 2560;
                  y = 140;
                  width = 1920;
                  height = 1080;
                  refreshRate = 143.981;
                };
                HDMI-A-2 = HDMI-A-1;

                DP-1 = {
                  enabled = true;
                  primary = false;
                  x = 0;
                  y = 0;
                  width = 2560;
                  height = 1440;
                  refreshRate = 74.932;
                };
                DP-2 = DP-1;
                DP-3 = DP-1;

                eDP-1 = {
                  enabled = true;
                  primary = false;
                  x = 629;
                  y = 1440;
                  width = 2560;
                  height = 1600;
                  refreshRate = 60.009;
                  scale = 2.0;
                };
              };
            };
          };
        };
      };

      nixpkgs.overlays = [
        (final: prev: {
          libfprint = prev.libfprint.overrideAttrs (oldAttrs: {
            version = "git";
            src = final.fetchFromGitHub {
              owner = "deftdawg";
              repo = "libfprint-CS9711";
              rev = "56bf490f8ea2ab9049f410b9dfe78b33d59fd2c4";
              sha256 = "sha256-PVr/Mi3m0P1bojVYriubmpA8QC5oayV5RtHbyXyHPC0=";
            };
            patches = []; # stock patches don't apply to this fork's source tree
            nativeBuildInputs =
              oldAttrs.nativeBuildInputs
              ++ [
                final.opencv
                final.cmake
                final.doctest
              ];
          });
        })
      ];
    };
  };

  flake.nixosModules."${host}-hardware" = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "sdhci_pci"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/a382f749-eb68-4cd7-b3ac-4e96d34eb719";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/E84A-8A5C";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    fileSystems."/home/aaronv/shared-home" = {
      device = "/dev/disk/by-uuid/6AB20C7DB20C504D";
      fsType = "ntfs";
      options = ["users" "nofail" "exec" "rw" "uid=1000" "gid=100"];
    };

    swapDevices = [];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp195s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
