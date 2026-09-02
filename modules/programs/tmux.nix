{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.tmux = {
    getPackage = self.wrappers.tmux.wrap;
    nixos = {
      user,
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
      scriptsPkgs = [
        (pkgs.writeShellScriptBin "sessions" (self.dotfiles.tmux.scripts.sessions {}))
        (pkgs.writeShellScriptBin "toggle-tmux-popup" (self.dotfiles.tmux.scripts.toggle-tmux-popup {}))
      ];
    in {
      environment.systemPackages = mkIf (user == null) ([package] ++ scriptsPkgs);
      users.users = mkIf (user != null) {
        "${user.name}".packages = [package] ++ scriptsPkgs;
      };
    };
  };
  flake.wrappers.tmux = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      wlib.wrapperModules.tmux
      self.modules.generic.colors
    ];

    config = let
      colors = config.preferences.theme.colors;
    in
      self.dotfiles.tmux.default {inherit pkgs colors;};
  };
}
