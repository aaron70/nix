{self, ...}: {
  anvil.programs.atuin = {
    getPackage = {pkgs, ...}: self.wrappers.atuin.wrap {inherit pkgs;};
  };

  flake.wrappers.atuin = {wlib, ...}: {
    imports = [wlib.wrapperModules.atuin];
    config.settings = fromTOML (self.dotfiles.atuin.default {});
  };
}
