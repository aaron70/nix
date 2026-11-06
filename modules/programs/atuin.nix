{self, ...}: {
  anvil.programs.atuin = {
    getPackage = {pkgs, ...}: self.wrappers.atuin.wrap {inherit pkgs;};
    nixos = {
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      # Atuin ships its zsh completion (_atuin) in site-functions.
      anvil.shell.preferences.activationScripts = [
        "fpath=(${package}/share/zsh/site-functions $fpath)"
      ];
    };
  };

  flake.wrappers.atuin = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.wrapperModules.atuin];
    settings = fromTOML (self.dotfiles.atuin.default {});
    runtimePkgs = with pkgs; [tmux];
  };
}
