{
  self,
  lib,
  config,
  ...
} @ global:
with lib; let
  mkIfUser = user: mkIf (user != null);
  defaultConfiguration = with config.anvil; rec {
    shell.name = "zsh";
    shell.editor.config = programs.editor.metadata;
    shell.prompt.name = "oh-my-posh";
    shell.multiplexer.name = "tmux";
    shell.config = {
      pkgs,
      config,
      ...
    }:
      with pkgs; let
        atuin = programs.atuin.getPackage {inherit pkgs;};
        editor = programs.editor.getPackage {
          inherit pkgs;
          metadata = shell.editor.config;
        };
        git = programs.git.getPackage {inherit pkgs config;};
        # tmux = programs.tmux.getPackage {inherit pkgs;};
      in rec {
        prompt.name = shell.prompt.name;
        prompt.getPackage = programs.${prompt.name}.getPackage;
        prompt.activationScript = self.dotfiles.oh-my-posh.activationScript.zsh {inherit prompt pkgs;};

        multiplexer.name = shell.multiplexer.name;
        multiplexer.getPackage = programs.${multiplexer.name}.getPackage;
        multiplexer.activationScript = self.dotfiles.tmux.activationScript.default {inherit multiplexer pkgs;};

        activationScripts = [
          "command -v fzf &>/dev/null && _anvil_cache_source fzf ${fzf}/bin/fzf --zsh"
          "command -v zoxide &>/dev/null && _anvil_cache_source zoxide ${zoxide}/bin/zoxide init zsh --cmd cd"
          "command -v direnv &>/dev/null && _anvil_cache_source direnv ${direnv}/bin/direnv hook zsh"
          # "eval \"$(${atuin}/bin/atuin init zsh --disable-up-arrow)\""
          "command -v atuin &>/dev/null && _anvil_cache_source atuin ${atuin}/bin/atuin init zsh"
        ];

        packages = [
          (multiplexer.getPackage {inherit pkgs;})
          (prompt.getPackage {inherit pkgs;})
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
          # tmux
          unixtools.watch
          zoxide
          (
            if shell.editor.config.isTerminalBased
            then editor
            else null
          )
          (
            if pkgs.stdenv.hostPlatform.isLinux
            then wl-clipboard
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

  commonModule = {
    host,
    program,
    user,
    pkgs,
    config,
    ...
  }: {
    fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
    users.users = mkIfUser user {
      ${user.name} = {
        shell = with program; getPackage {inherit pkgs metadata config host;};
      };
    };
  };
in {
  anvil.programs.shell = {
    metadata = defaultConfiguration;
    getPackage = {
      pkgs,
      config,
      metadata,
      host,
      ...
    }:
      global.config.anvil.programs.${metadata.shell.name}.getPackage {
        inherit pkgs;
        configuration =
          (metadata.shell.config {inherit pkgs config;})
          // {
            envVariables = {
              NH_FLAKE = host.metadata.nixPath;
            };

            shellAliases = let
              nixFlakePath = host.metadata.nixPath;
            in {
              ntest = "nh os test ${nixFlakePath} -H ${host.name}";
              nboot = "nh os boot ${nixFlakePath} -H ${host.name}";
              nswitch = "nh os switch ${nixFlakePath} -H ${host.name}";
              nbuild-vm = "nh os build-vm ${nixFlakePath} -H ${host.name}";
              nclean = "nh clean all --optimise -k ${toString host.metadata.configurationLimit}";
              nshell = "nix-shell --command ${metadata.shell.name} -p";
            };
          };
      };
    programs = {program, ...}: ([
        "git"
        program.metadata.shell.multiplexer.name
        program.metadata.shell.prompt.name
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
    nixos = commonModule;
    darwin = commonModule;
  };

  flake.wrappers.shell = {...}:
    with defaultConfiguration; {
      imports = [
        self.wrapperModules.${shell.name}
        shell.config
      ];
    };
}
