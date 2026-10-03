{
  inputs,
  self,
  lib,
  config,
  ...
} @ global:
with lib; {
  anvil.programs.umbriel = {
    programs = [
      "desktop"
      "noctalia"
    ];
    getPackage = {
      pkgs,
      options,
      ...
    }:
      self.wrappers.umbriel.wrap {
        inherit pkgs;
        imports = [
          (self.lib.usePreferences "desktop" options)
        ];
      };
    nixos = {
      user,
      program,
      pkgs,
      options,
      ...
    }: let
      package = program.getPackage {inherit pkgs options;};
    in {
      imports = [inputs.umbriel.nixosModules.default];
      programs.umbriel = {
        enable = true;
        package = package;
      };
    };
    home = {config, ...}: {
      imports = [
        inputs.umbriel.homeModules.default
        self.declarations.desktop
      ];
      programs.umbriel = {
        enable = true;
        settings = self.dotfiles.umbriel.default {config = config.anvil.desktop.preferences;};
      };
    };
  };

  flake.wrappers.umbriel = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      wlib.modules.default
      self.declarations.desktop
    ];

    passthru.providedSessions = ["umbriel"];
    package = pkgs.umbriel;
    # flags."-c" = pkgs.writeText "config.toml" (self.dotfiles.umbriel.toml {inherit config;}); # TODO: Currently not working, umbriel is not reading the configuration file from the nix store

    runtimePkgs = with pkgs; [
      xwayland-satellite
    ];

    env.FONTCONFIG_FILE = "${config.fontsConfig}";

    terminal = mkDefault (self.wrappers.terminal.wrap {inherit pkgs;});
    browser = mkDefault (global.config.anvil.programs.zen.getPackage {inherit pkgs;});
    desktopShell = mkDefault (global.config.anvil.programs.noctalia.getPackage {inherit pkgs;});
    appLauncher = mkDefault (pkgs.writeShellScriptBin "app-launcher" "${getExe config.desktopShell} msg panel-toggle launcher");
  };

  perSystem = {pkgs, ...}: {
    wrappers.packages.umbriel = pkgs.stdenv.hostPlatform.isDarwin;
  };
}
