{
  self,
  lib,
  config,
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
      self.wrappers.desktop.wrap {
        inherit pkgs;
        imports = [
          preferences
        ];
      };
    features = [
      "usb"
    ];
    programs = {program, ...}: [
      program.metadata.desktop.name
      program.metadata.desktop.desktopShell.name
    ];
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

  flake.wrappers.desktop = {...}:
    with defaultConfiguration; {
      imports = [
        self.wrapperModules.niri
      ];
    };
}
