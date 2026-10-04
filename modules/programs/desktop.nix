{
  self,
  lib,
  config,
  ...
} @ global:
with lib; {
  anvil.programs.desktop = {
    programs = [
      "terminal"
    ];
    features = [
      "usb"
    ];
    home = {pkgs, ...}: {
      imports = [
        (self.lib.inheritPreferences "desktop" args [self.declarations.desktop])
      ];
      home.packages = [pkgs.fastfetch];
      xdg.mimeApps = mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
      };
    };
    nixos = {
      pkgs,
      config,
      ...
    } @ args: let
      noctalia = global.config.anvil.programs.noctalia.getPackage {inherit pkgs;};
      apps = rec {
        terminal = global.config.anvil.programs.terminal.getPackage {
          inherit pkgs;
          metadata.terminal.name = global.config.anvil.programs.terminal.metadata.terminal.name;
        };
        browser = global.config.anvil.programs.zen.getPackage {inherit pkgs;};
        desktopShell = global.config.anvil.programs.noctalia.getPackage {inherit pkgs;};
        appLauncher = pkgs.writeShellScriptBin "app-launcher" "${getExe desktopShell} msg panel-toggle launcher";
      };
    in {
      imports = [
        (self.lib.inheritPreferences "desktop" args [self.declarations.desktop])
      ];

      anvil.desktop.preferences.terminal = mkForce apps.terminal;
      anvil.desktop.preferences.browser = mkForce apps.browser;
      anvil.desktop.preferences.desktopShell = mkForce apps.desktopShell;
      anvil.desktop.preferences.appLauncher = mkForce apps.appLauncher;

      home-manager.sharedModules = [
        {
          anvil.desktop.preferences = lib.mkDefault config.anvil.desktop.preferences;
        }
      ];

      xdg.portal = {
        enable = true;
        # extraPortals = [pkgs.xdg-desktop-portal-umbriel];
        config.common.default = "*";
      };

      services.gvfs.enable = true;
      services.displayManager.gdm.enable = true;
      environment.systemPackages = with pkgs; [
        # Dependencies
        pavucontrol
        playerctl
        brightnessctl

        # Applications
        spotify
        mission-center
        (global.config.anvil.programs.zen.getPackage {inherit pkgs;}) # Browser

        # Essentials
        nautilus # File browser
        vlc # Videos
        shotwell # Images
        wdisplays
        xdg-desktop-portal-gnome
        (pkgs.writeShellScriptBin "clipboard-history" "${getExe noctalia} msg panel-toggle clipboard")
        (pkgs.writeShellScriptBin "nixpkgs-search" ''
          query=$(echo "" | ${getExe noctalia} dmenu -p "Search nixpkgs: ")
          [ -n "$query" ] && ${pkgs.xdg-utils}/bin/xdg-open "https://search.nixos.org/packages?query=''${query// /+}"
        '')
        ddcutil
      ];
    };
  };
}
