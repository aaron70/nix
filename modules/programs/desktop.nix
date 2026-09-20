{
  self,
  lib,
  ...
} @ global:
with lib; let
  defaultConfiguration = {
    desktop.name = "niri";
    desktop.desktopShell.name = "noctalia";
    desktop.apps = {pkgs, ...}: rec {
      terminal = global.config.anvil.programs.terminal.getPackage {
        inherit pkgs;
        metadata.terminal.name = global.config.anvil.programs.terminal.metadata.terminal.name;
      };
      browser = global.config.anvil.programs.zen.getPackage {inherit pkgs;};
      desktopShell = global.config.anvil.programs.noctalia.getPackage {inherit pkgs;};
      appLauncher = pkgs.writeShellScriptBin "app-launcher" "${getExe desktopShell} msg panel-toggle launcher";
    };
  };
in {
  anvil.programs.desktop = {
    metadata = defaultConfiguration;
    getPackage = {
      pkgs,
      preferences ? {},
      ...
    }:
      if pkgs.stdenv.hostPlatform.isLinux
      then
        self.wrappers.desktop.wrap {
          inherit pkgs;
          imports = [preferences];
        }
      else
        self.wrappers.desktop-darwin.wrap {
          inherit pkgs;
          imports = [preferences];
        };
    features = [
      "usb"
    ];
    programs = {program, ...}: [
      program.metadata.desktop.name
      program.metadata.desktop.desktopShell.name
    ];
    home = {pkgs, ...}: {
      home.packages = [pkgs.fastfetch];
      xdg.mimeApps = mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
      };
    };
    nixos = {
      user,
      program,
      pkgs,
      config,
      ...
    }: let
      apps = program.metadata.desktop.apps {inherit pkgs;};
      package = program.getPackage {
        inherit pkgs;
        preferences = config.anvil.desktop.preferences;
      };
    in {
      imports = [
        (self.lib.installPackages user [package])
      ];

      options = {
        anvil.desktop.preferences = mkOption {
          type = types.submodule {
            _module.args.pkgs = pkgs;
            imports = [
              self.declarations.desktop
            ];
          };
        };
      };

      config = {
        xdg.portal = {
          enable = true;
          extraPortals = [pkgs.xdg-desktop-portal-gtk];
          config.common.default = "*";
        };

        anvil.desktop.preferences.terminal = mkForce apps.terminal;
        anvil.desktop.preferences.browser = mkForce apps.browser;
        anvil.desktop.preferences.desktopShell = mkForce apps.desktopShell;
        anvil.desktop.preferences.appLauncher = mkForce apps.appLauncher;

        programs.${program.metadata.desktop.name} = {
          enable = true;
          package = package;
        };

        services.gvfs.enable = true;
        services.displayManager.gdm.enable = true;
        environment.systemPackages = with pkgs;
          [
            # Dependencies
            pavucontrol
            playerctl
            brightnessctl

            # Applications
            spotify
            mission-center

            # Essentials
            nautilus # File browser
            vlc # Videos
            shotwell # Images
            wdisplays
            xdg-desktop-portal-gnome
            (pkgs.writeShellScriptBin "clipboard-history" "${getExe apps.desktopShell} msg panel-toggle clipboard")
            (pkgs.writeShellScriptBin "nixpkgs-search" ''
              query=$(echo "" | ${getExe apps.desktopShell} dmenu -p "Search nixpkgs: ")
              [ -n "$query" ] && ${pkgs.xdg-utils}/bin/xdg-open "https://search.nixos.org/packages?query=''${query// /+}"
            '')
            ddcutil
          ]
          ++ (attrValues apps);
      };
    };
  };

  flake.wrappers.desktop = {...}: {
    imports = [
      self.wrapperModules.niri
    ];
  };

  flake.wrappers.desktop-darwin = {...}: {
    imports = [
      self.wrapperModules.aerospace
    ];
  };

  perSystem = {pkgs, ...}: {
    wrappers.packages.desktop = pkgs.stdenv.hostPlatform.isDarwin;
    wrappers.packages.desktop-darwin =
      !(pkgs.stdenv.hostPlatform.isAarch64 && pkgs.stdenv.hostPlatform.isDarwin);
  };
}
