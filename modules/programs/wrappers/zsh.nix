{ self, lib, ... }: 

with lib;
let
  name = "zsh";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({ ... }: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({ ... }: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ ... }: {});

  flake.programs.${name} = self.lib.mkProgram name ({ ... }: {
    configurations = [ self.definitions.programs.shell ];
  });

  flake.wrappers.${name} = { wlib, pkgs, config, ... }:
  {
    imports = [ 
      wlib.wrapperModules.zsh
      (self.lib.mkConfigurationsOption [ self.definitions.programs.shell ])
    ];

    config = with pkgs; {
      env = config.configurations.envVariables;
      zshAliases = config.configurations.shellAliases;

      extraPackages = [
        #wrapped
        config.configurations.shellPrompt
      ] ++ config.configurations.packages;

      zshrc.content = ''
        autoload -Uz compinit
        if [[ -x $(command -v fzf) ]]; then eval "$(fzf --zsh)"; fi
         
        typeset -i updated_at=$(date +'%j' -r $HOME/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' $HOME/.zcompdump 2>/dev/null)
        typeset -i today=$(date +'%j')
         
        if [[ $updated_at -eq $today ]]; then
          compinit -C -i
        else
          compinit -i
        fi

        zmodload -i zsh/complist


        # ==============================
        # Environment Varialbes
        # ==============================

        # History configurations
        HISTFILE=$HOME/.zsh_history
        HISTSIZE=100000
        HISTDUP=erase
        SAVEHIST=$HISTSIZE

        # Autosuggest configurations
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

        # Stop zsh autocorrect from suggesting undesired completions
        CORRECT_IGNORE_FILE=".*"
        CORRECT_IGNORE="_*"


        # ==============================
        # ZSH Options
        # ==============================

        setopt auto_cd
        setopt correct_all
        setopt interactive_comments

        # History configurations
        setopt hist_expire_dups_first
        setopt hist_find_no_dups
        setopt hist_ignore_space
        setopt hist_ignore_all_dups
        setopt hist_reduce_blanks
        setopt hist_save_no_dups
        setopt hist_verify
        setopt inc_append_history
        setopt share_history

        # Autosuggest configurations
        setopt auto_list
        setopt auto_menu
        setopt always_to_end


        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:*' use-fzf-default-opts yes

        # ==============================
        # vi Mode
        # ==============================

        bindkey -v
        bindkey -M viins 'jk' vi-cmd-mode

        # Cursor shape: block in normal, beam in insert
        function zle-keymap-select {
          if [[ $KEYMAP == vicmd ]]; then
            echo -ne '\e[1 q'   # block cursor
          else
            echo -ne '\e[5 q'   # beam cursor
          fi
        }
        zle -N zle-keymap-select
        
        function zle-line-init {
          echo -ne '\e[5 q'     # beam cursor on new prompt
        }
        zle -N zle-line-init


        # ==============================
        # Keybindings
        # ==============================

        bindkey ' ' magic-space

        # History keybindings
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down

        # Autosuggest keybindings
        bindkey '^y' autosuggest-accept

        # Edit command buffer
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey '^ e' edit-command-line


        # ==============================
        # Hooks
        # ==============================
        autoload -Uz add-zsh-hook
        
        # Reference: https://gist.github.com/elliottminns/09a598082d77f795c88e93f7f73dba61
        
        function auto_venv() {
          # If already in a virtualenv, do nothing
          if [[ -n "$VIRTUAL_ENV" && "$PWD" != *"''${VIRTUAL_ENV:h}"* ]]; then
            deactivate
            return  
          fi
        
          [[ -n "$VIRTUAL_ENV" ]] && return
        
          local dir="$PWD"
          while [[ "$dir" != "/" ]]; do
            if [[ -f "$dir/.venv/bin/activate" ]]; then
              source "$dir/.venv/bin/activate"
              return
            fi
            dir="''${dir:h}"
          done
        }
        
        function auto_nix() {
          # If we're already in a nix develop shell, do nothing
          [[ -n "$IN_NIX_SHELL" ]] && return
        
          # Walk up to find a flake
          local dir="$PWD"
          while [[ "$dir" != "/" ]]; do
            if [[ -f "$dir/flake.nix" ]]; then
              # If this project already has .envrc, just allow it (you can remove this if you prefer)
              if [[ ! -f "$dir/.envrc" ]]; then
                # Create .envrc that loads the dev env (fast, no interactive shell)
                cat > "$dir/.envrc" <<'EOF'
        # autogenerated: load flake dev environment
        eval "$(nix print-dev-env)"
        EOF
                command direnv allow "$dir" >/dev/null 2>&1
              fi
        
              command direnv reload >/dev/null 2>&1
              return
            fi
            dir="''${dir:h}"
          done
        }
        
        function auto_nvm() {
          [[ -f .nvmrc ]] && nvm use
        }

        function auto_ls() {
          BLUE='\033[0;34m'
          NOCOLOR='\033[0m'
          count=$(fd -d 1 --max-results 26 | wc -l)
          if [ $count -le 25 ]; then
            echo " ''${BLUE}  ''${NOCOLOR}files at ''${BLUE}$(pwd)''${NOCOLOR}:"
            ls
          else
            echo " ''${BLUE}  ''${NOCOLOR}there are more than 25 files at ''${BLUE}$(pwd)''${NOCOLOR}"
          fi
        }
        
        add-zsh-hook chpwd auto_venv
        add-zsh-hook chpwd auto_nix
        add-zsh-hook chpwd auto_nvm
        add-zsh-hook chpwd auto_ls

        # ==============================
        # Plugins
        # ==============================
        # KEYTIMEOUT=1
        # ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
        # ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
        # source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        source ${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source ${zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
          eval "$(${getExe' config.configurations.shellPrompt "oh-my-posh"} init zsh)"
        fi

        if [[ "$TMUX" == "" ]]; then
          if [[ "$(tmux ls 2>/dev/null)" == "" ]]; then
            tmux new -s kyoten
          fi
          sesh connect kyoten 
        fi
      '';
    };
  };
}
