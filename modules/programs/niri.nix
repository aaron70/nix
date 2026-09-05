{
  self,
  lib,
  config,
  ...
} @ global:
with lib; let
  commonModule = {
    user,
    program,
    pkgs,
    ...
  }: let
    package = program.getPackage {inherit pkgs;};
  in {
    environment.systemPackages = mkIf (user == null) [package];
    users.users = mkIf (user != null) {
      ${user.name}.packages = [package];
    };
  };
in {
  anvil.programs.niri = {
    getPackage = self.wrappers.niri.wrap;
    nixos = commonModule;
    darwin = commonModule;
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

    terminal = global.config.anvil.programs.terminal.getPackage {
      inherit pkgs;
      metadata.terminal.name = global.config.anvil.programs.terminal.metadata.terminal.name;
    };
    browser = global.config.anvil.programs.zen.getPackage {inherit pkgs;};
    desktopShell = global.config.anvil.programs.noctalia.getPackage {inherit pkgs;};
    appLauncher = pkgs.writeShellScriptBin "app-launcher" "${getExe config.desktopShell} msg panel-toggle launcher";
    "config.kdl".content = self.dotfiles.niri.default {inherit config;};
  };
}
