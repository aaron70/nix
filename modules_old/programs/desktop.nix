{
  inputs,
  self,
  lib,
  ...
}:
with lib; let
  name = "desktop";
  desktop = "niri";
  bar = "noctalia";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({...}: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({...}: {
    config = {
      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };
      services.udiskie = {
        enable = true;
      };
    };
  });

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({
    pkgs,
    cfg,
    config,
    ...
  }: {
    config = let
      bar-shell = self.wrappers.${bar}.wrap {inherit pkgs;};
    in {
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      preferences.programs.terminal.enable = mkDefault true;
      preferences.programs.${bar}.enable = mkDefault true;
      services.displayManager.gdm.enable = true;
      programs.${desktop} = {
        enable = true;
        package = self.wrappers.${name}.wrap {
          inherit pkgs;
          configurations = cfg.configurations;
        };
      };

      environment.systemPackages = with pkgs;
        [
          # Applications
          spotify

          # Essentials
          nautilus # File browser
          vlc # Videos
          shotwell # Images
          mission-center
          wdisplays
          xdg-desktop-portal-gnome
          (pkgs.writeShellScriptBin "clipboard-history" "${getExe bar-shell} msg panel-toggle clipboard")
          (pkgs.writeShellScriptBin "nixpkgs-search" ''
            query=$(echo "" | ${getExe bar-shell} dmenu -p "Search nixpkgs: ")
            [ -n "$query" ] && ${pkgs.xdg-utils}/bin/xdg-open "https://search.nixos.org/packages?query=''${query// /+}"
          '')
          ddcutil
        ]
        ++ cfg.configurations.packages;

      systemd.services.lock-before-suspend = {
        enable = true;
        description = "Locks the session before sleep";
        wantedBy = ["sleep.target"];
        before = ["sleep.target"];
        serviceConfig = {
          Type = "oneshot";
          User = config.profile.user.username;
          ExecStart = pkgs.writeShellScript "lock-screen" ''
            set -e
            ${getExe bar-shell} msg session lock

            for i in $(seq 1 20); do
              locked=$(${getExe bar-shell} msg status | ${getExe pkgs.jq} .locked)
              if [ "$locked" = "true" ]; then
                exit 0
              fi
              sleep 0.1
            done

            echo "Timed out waiting for session lock" >&2
            exit 1
          '';
        };
        environment = {
          XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${config.profile.user.username}.uid}";
          WAYLAND_DISPLAY = "wayland-1";
        };
      };
    };
  });

  flake.programs.${name} = self.lib.mkProgram name ({...}: {
    configurations = [self.definitions.programs.${name}];
  });

  flake.wrappers.${name} = {...}: {
    imports = [
      self.wrapperModules.${desktop}
    ];
  };

  flake.definitions.programs.${name} = {pkgs, ...}: {
    options = {
      modKey = mkOption {
        type = types.str;
        description = "The mod key to be used by the window manager.";
        default = "super";
      };

      modKeyAlt = mkOption {
        type = types.str;
        description = "The alternative mod key to be used by the window manager.";
        default = "alt";
      };

      terminal = mkOption {
        type = types.package;
        description = "The wrapped and configured terminal package.";
      };

      browser = mkOption {
        type = types.package;
        description = "The wrapped and configured browser package.";
      };

      desktopShell = mkOption {
        type = types.package;
        description = "The wrapped and configured desktop shell package.";
      };

      appLauncher = mkOption {
        type = types.package;
        description = "The wrapped and configured app launcher package.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        description = "An list of packages to install.";
      };

      fontsConfig = mkOption {
        type = types.package;
        description = "The package with the font configurations. Export FONTCONFIG_FILE=\${fontsConfig} to apply the fonts.";
        default = pkgs.makeFontsConf {
          fontDirectories = with pkgs; [
            nerd-fonts.jetbrains-mono
          ];
        };
      };

      monitors = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            primary = mkOption {
              type = types.bool;
              default = false;
            };
            width = mkOption {
              type = types.int;
              example = 1920;
            };
            height = mkOption {
              type = types.int;
              example = 1080;
            };
            refreshRate = mkOption {
              type = types.float;
              default = 60;
            };
            x = mkOption {
              type = types.int;
              default = 0;
            };
            y = mkOption {
              type = types.int;
              default = 0;
            };
            scale = mkOption {
              type = types.float;
              default = 1.0;
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
            };
          };
        });
        default = {};
      };
    };

    config = let
      bar-shell = self.wrappers.${bar}.wrap {inherit pkgs;};
    in rec {
      terminal = mkDefault (self.wrappers.terminal.wrap {inherit pkgs;});
      browser = mkDefault inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
      desktopShell = mkDefault bar-shell;
      appLauncher = mkDefault (pkgs.writeShellScriptBin "app-launcher" "${getExe bar-shell} msg panel-toggle launcher");
      packages = with pkgs;
        mkDefault [
          # Wrappers
          terminal
          browser
          desktopShell
          appLauncher

          alacritty

          # Dependencies
          pavucontrol
          playerctl
          brightnessctl
        ];
    };
  };
}
