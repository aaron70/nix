{lib, ...}:
with lib; {
  flake.declarations.desktop = {pkgs, ...}: {
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
  };
}
