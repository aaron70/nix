{
  self,
  lib,
  config,
  ...
} @ global:
with lib; let
in {
  anvil.programs.niri = {
    getPackage = self.wrappers.niri.wrap;
    nixos = {
      user,
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      programs.niri.enable = true;
      programs.niri.package = package;
    };
  };

  flake.wrappers.niri = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      wlib.wrapperModules.niri
      self.declarations.desktop
    ];

    passthru.providedSessions = ["niri"];
    runtimePkgs = with pkgs; [
      xwayland-satellite
      jq
    ];

    env.FONTCONFIG_FILE = "${config.fontsConfig}";

    terminal = self.wrappers.terminal.wrap {inherit pkgs;};
    browser = global.config.anvil.programs.zen.getPackage {inherit pkgs;};
    desktopShell = global.config.anvil.programs.noctalia.getPackage {inherit pkgs;};
    appLauncher = pkgs.writeShellScriptBin "app-launcher" "${getExe config.desktopShell} msg panel-toggle launcher";
    "config.kdl".content = self.dotfiles.niri.default {inherit config;};
  };
}
