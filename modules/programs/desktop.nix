{ self, lib, ... }: 

with lib;
let
  desktop = "niri";
in {

  flake.nixosModules.desktop = { pkgs, config, ... }: {
    imports = [
      self.modules.generic.desktop
      self.nixosModules.terminal
    ];

    options.preferences.desktop = {
      enable = mkEnableOption "Whether to enable the desktop environment.";
    };

    config = mkIf config.preferences.desktop.enable {
      services.displayManager.gdm.enable = true;
      programs.${desktop} = {
        enable = true;
        package = self.wrappers.desktop.wrap { 
          inherit pkgs; 
        };
      };
    };
  };

  flake.wrappers.desktop = { pkgs, ... }: {
    imports = [
      self.wrapperModules.${desktop}
    ];

    config = let
      fontsConfig = pkgs.makeFontsConf {
        fontDirectories = with pkgs; [
          nerd-fonts.jetbrains-mono
        ];
      };
    in {
      env.FONTCONFIG_FILE="${fontsConfig}";
    };
  };

  flake.modules.generic.desktop = { pkgs, ... }: {
    options.configurations = {
      terminal = mkOption {
        type = types.package;
        description = "The wrapped and configured terminal package.";
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

      fonts = mkOption {
        type = types.listOf types.package;
        description = "An of fonts to install.";
      };
    };

    config.configurations = rec {
      terminal = self.wrappers.terminal.wrap { inherit pkgs; };
      desktopShell = self.wrappers.noctalia.wrap { inherit pkgs; };
      # appLauncher = pkgs.fuzzel;
      appLauncher = (pkgs.writeShellScriptBin "launcher" "${getExe desktopShell} ipc call launcher toggle");

      packages = [
        terminal
        desktopShell
        appLauncher
      ];
    };
  };
}
