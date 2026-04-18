{ inputs, self, lib, ... }: 

with lib;
let
  name = "desktop";
  desktop = "niri";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({ ... }: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({ ... }: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ pkgs, cfg, ... }: {
    config = {
      preferences.programs.terminal.enable = mkDefault true;
      services.displayManager.gdm.enable = true;
      programs.${desktop} = {
        enable = true;
        package = self.wrappers.${name}.wrap { 
          inherit pkgs;
          configurations = cfg.configurations;
        };
      };

      environment.systemPackages = with pkgs; [
        # Applications
        spotify

        # Essentials
        vlc # Videos
        shotwell # Images
        mission-center
      ] ++ cfg.configurations.packages;
    };
  });

  flake.programs.${name} = self.lib.mkProgram name ({ ... }: {
    configurations = [ self.definitions.programs.${name} ];
  });

  flake.wrappers.${name} = { ... }: {
    imports = [
      self.wrapperModules.${desktop}
    ];
  };

  flake.definitions.programs.${name} = { pkgs, ... }: {
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
      noctalia-shell = (self.wrappers.noctalia.wrap { inherit pkgs; });
    in rec {
      terminal = mkDefault (self.wrappers.terminal.wrap { inherit pkgs; });
      browser = mkDefault inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
      desktopShell = mkDefault noctalia-shell;
      appLauncher = mkDefault (pkgs.writeShellScriptBin "launcher" "${getExe noctalia-shell} ipc call launcher toggle");
      packages = with pkgs; mkDefault  [
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
