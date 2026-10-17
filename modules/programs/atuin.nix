{self, ...}: {
  anvil.programs.atuin = {
    getPackage = {pkgs, ...}: self.wrappers.atuin.wrap {inherit pkgs;};
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
