{ inputs, self, lib, ... }: 

with lib;
let
  name = "shell";
  shell = "zsh";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({ ... }: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({ ... }: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ config, cfg, ... }: let
    shellPackage = cfg.package; 
  in {
    config = {
      programs.${shell}.enable = true;
      environment.pathsToLink = [ "/share/${shell}" ];

      users.defaultUserShell = shellPackage;
      users.users.${config.profile.user.username}.shell = shellPackage;

      environment.systemPackages = [
        shellPackage
      ] ++ cfg.configurations.packages;

      environment.variables = rec {
        GIT_AUTHOR_NAME = config.profile.user.username;
        GIT_AUTHOR_EMAIL = config.profile.user.email;
        GIT_COMMITER_NAME = GIT_AUTHOR_NAME;
        GIT_COMMITER_EMAIL = GIT_AUTHOR_EMAIL;
        NH_FLAKE = "/home/${config.profile.user.username}/nix";
      };

      environment.shellAliases = let
        homePath = "/home/${config.profile.user.username}/nix";
      in {
        ntest = "nh os test ${homePath} -H ${config.information.hostname}";
        nswitch = "nh os switch ${homePath} -H ${config.information.hostname}";
        nbuild-vm = "nh os build-vm ${homePath} -H ${config.information.hostname}";
        nclean = "nh clean all --optimise -k ${toString config.preferences.boot.configurationLimit}";
      };
    };
  });

  flake.programs.${name} = self.lib.mkProgram name ({ pkgs, cfg, ... }: {
    configurations = [ self.definitions.programs.${name} ];
    config = {
      package = self.wrappers.${name}.wrap {
        inherit pkgs;
        configurations = ({
          multiplexer = let shellPath = getExe cfg.package; in mkDefault (self.wrappers.tmux.wrap {
            inherit pkgs; 
            shell = shellPath;
          });
          packages = [ multiplexer ];
        } // cfg.configurations);
      };
    };
  });

  flake.wrappers.${name} = { pkgs, config, ... }: {
    imports = [
      self.wrapperModules.${shell}
    ];

    config.configurations = rec {
      multiplexer = let shellPath = getExe config.package; in mkDefault (self.wrappers.tmux.wrap {
        inherit pkgs; 
        shell = shellPath;
      });
      packages = [ multiplexer ];
    };
  };

  flake.definitions.programs.${name} = { pkgs, ... }: {
    options = {
      shellAliases = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        description = "An attrSet with shell aliases.";
        default = {
          cat = "bat";
          lg = "lazygit";
          eza = "eza --icons auto --git --group-directories-last";
          ls = "eza";
          find = "fd";
          cd = ". cdfzf";
          nshell = "nix-shell -p";
        };
      };

      envVariables = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        description = "An attrSet with environment variables.";
        default = {
          EDITOR = "nvim";
          SHELL = shell;
          TERM = "tmux-256color";
        };
      };

      packages = mkOption {
        type = types.listOf types.package;
        description = "An list of packages to install.";
      };

      shellPrompt = mkOption {
        type = types.package;
        description = "The shell prompt package.";
        default = self.wrappers.oh-my-posh.wrap { inherit pkgs; };
      };

      multiplexer = mkOption {
        type = types.package;
        description = "The wrapped and configured terminal multiplexer.";
      }; 
    };

    config = {
      packages = with pkgs; [
        # Dependencies
        bat
        chafa
        eza
        fd
        file
        fzf
        gcc
        gh
        git
        git-crypt
        imgcat
        lazygit
        nh
        ripgrep
        sesh
        television
        wl-clipboard
        zoxide

        # Wrapped
        inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.nvim

        # Scripts
        (writeShellScriptBin "hydrate-paths" (readFile ./scripts/hydrate-paths.sh))
        (writeShellScriptBin "custom-fzf-preview" (readFile ./scripts/custom-fzf-preview.sh))
        (writeShellScriptBin "cdfzf" (readFile ./scripts/cdfzf.sh))
        (writeShellScriptBin "toggle-tmux-popup" (readFile ./scripts/toogle-tmux-popup.sh))
        (writeShellScriptBin "sessions" (readFile ./scripts/sessions.sh))
      ];
    };
  };
}
