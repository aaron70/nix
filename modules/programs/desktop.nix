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
  commonModule = {
    user,
    program,
    pkgs,
    ...
  }: let
    package = program.getPackage {inherit pkgs program;};
  in {
    environment.systemPackages = mkIf (user == null) [package];
    users.users = mkIf (user != null) {
      ${user.name}.packages = [package];
    };
  };
in {
  anvil.programs.desktop = {
    metadata = defaultConfiguration;
    getPackage = {
      program,
      pkgs,
      preferences ? {},
      ...
    }:
      with program.metadata; let
        apps = desktop.apps {inherit pkgs;};
      in
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
      ...
    }: let
      apps = program.metadata.desktop.apps {inherit pkgs;};
    in {
      imports = [
        (self.lib.withContext {inherit user program;} commonModule)
      ];

      options = {
        anvil.desktop.preferences = mkOption {
          type = types.submoduleOf {
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
    darwin = commonModule;
  };

  flake.wrappers.desktop = {...}:
    with defaultConfiguration; {
      imports = [
        self.wrapperModules.${desktop.name}
      ];
    };
}
