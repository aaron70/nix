{
  self,
  config,
  lib,
  ...
} @ global:
with lib; {
  flake.dotfiles.shell.getConfiguration = {defaultConfiguration}: ({
    pkgs,
    config,
    ...
  }:
    with defaultConfiguration; {
      config = with config; {
        metadata = {
          wrappers = {
            atuin = self.wrappers.atuin.wrap {inherit pkgs;};
            editor = self.wrappers.editor.wrap {
              inherit pkgs;
              metadata.editor = global.config.anvil.programs.editor.metadata.editor;
            };
            git = self.wrappers.git.wrap {inherit pkgs;};
          };
        };

        prompt.name = shell.prompt.name;
        prompt.getPackage = {
          pkgs,
          tty ? false,
          ...
        }:
          if tty
          then self.wrappers."${prompt.name}-tty".wrap {inherit pkgs;}
          else self.wrappers.${prompt.name}.wrap {inherit pkgs;};
        prompt.activationScript = self.dotfiles.${prompt.name}.activationScript.${shell.name} {inherit prompt pkgs;};

        multiplexer.name = shell.multiplexer.name;
        multiplexer.getPackage = self.wrappers.${multiplexer.name}.wrap;
        multiplexer.activationScript = self.dotfiles.${multiplexer.name}.activationScript.${shell.name} {inherit pkgs multiplexer;};

        activationScripts = with pkgs; [
          "command -v fzf &>/dev/null && _anvil_cache_source fzf ${fzf}/bin/fzf --zsh"
          "command -v zoxide &>/dev/null && _anvil_cache_source zoxide ${zoxide}/bin/zoxide init zsh --cmd cd"
          # "command -v direnv &>/dev/null && _anvil_cache_source direnv ${direnv}/bin/direnv hook zsh"
          # "eval \"$(${atuin}/bin/atuin init zsh --disable-up-arrow)\""
          "command -v atuin &>/dev/null && _anvil_cache_source atuin ${atuin}/bin/atuin init zsh"
        ];

        packages = with pkgs;
        with config.metadata.wrappers; [
          (multiplexer.getPackage {inherit pkgs;})
          (prompt.getPackage {inherit pkgs;})

          # Wrapped
          atuin
          git
          (
            if global.config.anvil.programs.editor.metadata.isTerminalBased
            then editor
            else null
          )

          # Dependencies
          bat
          chafa
          direnv
          eza
          fd
          file
          fzf
          gcc
          gh
          imgcat
          jq
          lazygit
          nh
          ripgrep
          sesh
          unixtools.watch
          zoxide
          (
            if pkgs.stdenv.hostPlatform.isLinux
            then wl-clipboard
            else null
          )
        ];

        envVariables = {};

        shellAliases = {
          lg = "lazygit";
          nclean = "nh clean all --optimise -k 3";
          nshell = "nix-shell --command ${shell.name} -p";
        };
      };
    });
}
