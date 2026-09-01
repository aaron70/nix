{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.oh-my-posh = {
    getPackage = {
      pkgs,
      tty ? false,
      ...
    }:
      if tty
      then self.wrappers.oh-my-posh-tty.wrap {inherit pkgs;}
      else self.wrappers.oh-my-posh.wrap {inherit pkgs;};
  };

  flake.wrappers.oh-my-posh = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      wlib.wrapperModules.oh-my-posh
      self.modules.generic.colors
    ];
    config = let
      colors = config.preferences.theme.colors;
    in {
      runtimePkgs = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
      configFile = mkDefault (pkgs.writeText "config.json" (self.dotfiles.oh-my-posh.default {inherit colors;}));
    };
  };

  flake.wrappers.oh-my-posh-tty = {
    pkgs,
    config,
    ...
  }: let
    colors = config.preferences.theme.colors;
  in {
    imports = [self.wrapperModules.oh-my-posh];
    configFile = pkgs.writeText "config.json" (self.dotfiles.oh-my-posh.tty {inherit colors;});
  };
}
