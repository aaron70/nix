{
  self,
  lib,
  config,
  ...
}:
with lib; let
  mkIfUser = user: mkIf (user != null);
  defaultConfiguration = with config.anvil; rec {
    shell.name = "zsh";
    shell.editor.config = programs.editor.metadata;
    shell.config = {pkgs, ...}:
      with pkgs; let
        atuin = programs.atuin.getPackage {inherit pkgs;};
        editor = programs.editor.getPackage {
          inherit pkgs;
          metadata = shell.editor.config;
        };
        tmux = programs.tmux.getPackage {inherit pkgs;};
      in rec {
        prompt.name = "oh-my-posh";
        prompt.getPackage = programs.${prompt.name}.getPackage;
        prompt.activationScript = self.dotfiles.oh-my-posh.activationScript.zsh {inherit prompt pkgs;};

        multiplexer.name = "tmux";
        multiplexer.getPackage = programs.${multiplexer.name}.getPackage;
        multiplexer.activationScript = self.dotfiles.tmux.activationScript.default {inherit multiplexer pkgs;};

        activationScripts = [
          "command -v fzf &>/dev/null && _anvil_cache_source fzf ${fzf}/bin/fzf --zsh"
          "command -v zoxide &>/dev/null && _anvil_cache_source zoxide ${zoxide}/bin/zoxide init zsh --cmd cd"
          "command -v direnv &>/dev/null && _anvil_cache_source direnv ${direnv}/bin/direnv hook zsh"
          "command -v atuin &>/dev/null && _anvil_cache_source atuin ${atuin}/bin/atuin init zsh"
        ];

        packages = [
          # Dependencies
          atuin
          bat
          chafa
          direnv
          eza
          fd
          file
          fzf
          gcc
          gh
          git
          imgcat
          jq
          lazygit
          nh
          ripgrep
          sesh
          tmux
          unixtools.watch
          zoxide
          (
            if shell.editor.config.isTerminalBased
            then editor
            else null
          )
        ];

        envVariables = {
        };

        shellAliases = {
          lg = "lazygit";
        };
      };
  };
in {
  anvil.programs.shell = {
    metadata = defaultConfiguration;
    getPackage = {
      pkgs,
      metadata,
      ...
    }:
      config.anvil.programs.${metadata.shell.name}.getPackage {
        inherit pkgs;
        configuration = metadata.shell.config {inherit pkgs;};
      };
    programs = {program, ...}: ([
        "git"
      ]
      ++ (
        if program.metadata.shell.editor.config.isTerminalBased
        then [
          {
            ref = "editor";
            merge = {metadata = program.metadta.shell.editor.config;};
          }
        ]
        else []
      ));
    nixos = {
      host,
      program,
      user,
      pkgs,
      ...
    }: {
      environment.variables = {
        NH_FLAKE = host.metadata.nixPath;
      };

      fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
      environment.shellAliases = let
        nixFlakePath = host.metadata.nixPath;
      in {
        ntest = "nh os test ${nixFlakePath} -H ${host.name}";
        nswitch = "nh os switch ${nixFlakePath} -H ${host.name}";
        nbuild-vm = "nh os build-vm ${nixFlakePath} -H ${host.name}";
        nclean = "nh clean all --optimise -k ${toString host.metadata.configurationLimit}";
      };

      users.users = mkIfUser user {
        ${user.name} = {
          shell = with program; getPackage {inherit pkgs metadata;};
        };
      };
    };
    darwin = {
      user,
      pkgs,
      ...
    }: {
      environment.variables = {
        NH_FLAKE = host.metadata.nixPath;
      };
      fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
      users.users = mkIfUser user {
        ${user.name} = {
          shell = with program; getPackage {inherit pkgs metadata;};
        };
      };
    };
  };

  flake.wrappers.shell = {...}:
    with defaultConfiguration; {
      imports = [
        self.wrapperModules.${shell.name}
        shell.config
      ];
    };
}
