{
  self,
  lib,
  ...
} @ global:
with lib; {
  anvil.programs.niri = {
    getPackage = self.wrappers.niri.wrap;
    nixos = {
      program,
      pkgs,
      ...
    }: {
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

    terminal = mkDefault (self.wrappers.terminal.wrap {inherit pkgs;});
    browser = mkDefault (global.config.anvil.programs.zen.getPackage {inherit pkgs;});
    desktopShell = mkDefault (global.config.anvil.programs.noctalia.getPackage {inherit pkgs;});
    appLauncher = mkDefault (pkgs.writeShellScriptBin "app-launcher" "${getExe config.desktopShell} msg panel-toggle launcher");
    "config.kdl".content = self.dotfiles.niri.default {inherit config;};
  };

  perSystem = {pkgs, ...}: {
    wrappers.packages.niri = pkgs.stdenv.hostPlatform.isDarwin;
  };
}
