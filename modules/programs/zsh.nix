{
  self,
  lib,
  ...
}:
with lib; let
  commonModule = {
    program,
    pkgs,
    ...
  }: let
    package = with program.metadata; program.getPackage {inherit pkgs configuration;};
  in {
    programs.zsh.enable = true;
    environment.pathsToLink = ["/share/zsh"];
    environment.systemPackages = [package];
  };
in {
  anvil.programs.zsh = {
    getPackage = {
      pkgs,
      configuration,
      ...
    }:
      self.wrappers.zsh.wrap ({inherit pkgs;} // configuration);
    nixos = commonModule;
    darwin = commonModule;
  };

  flake.wrappers.zsh = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      wlib.wrapperModules.zsh
      self.declarations.shell
    ];

    config = with pkgs; {
      env = {} // config.envVariables;
      zshAliases = {} // config.shellAliases;
      runtimePkgs =
        [
          zsh-defer
          zsh-autosuggestions
          zsh-fast-syntax-highlighting
          zsh-history-substring-search
          zsh-fzf-tab
          zsh-completions
        ]
        ++ config.packages;

      zshrc.content = with config;
        self.dotfiles.zsh.default {
          inherit pkgs activationScripts prompt multiplexer;
        };
    };
  };
}
