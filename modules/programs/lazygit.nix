{...}: {
  anvil.programs.lazygit = {
    home = {...}: {
      programs.delta = {
        enable = true;
        options = {
          features = "tokyonight_night";

          # Brighter, more saturated diff colors (overrides the tokyonight palette)
          minus-style = "syntax #6e2634";
          minus-non-emph-style = "syntax #6e2634";
          minus-emph-style = "syntax #9e2e48";
          minus-empty-line-marker-style = "syntax #6e2634";
          line-numbers-minus-style = "#f7768e";
          plus-style = "syntax #2f5d32";
          plus-non-emph-style = "syntax #2f5d32";
          plus-emph-style = "syntax #437f3f";
          plus-empty-line-marker-style = "syntax #2f5d32";
          line-numbers-plus-style = "#9ece6a";
        };
      };

      programs.lazygit = {
        enable = true;

        settings = {
          gui = {
            showIcons = true;
            nerdFontsVersion = "3";
          };
          git = {
            disableForcePushing = true;
            autoForwardBranches = "none";
            diffRenderers = [
              {
                colorArg = "always";
                command = "delta --paging=never";
              }
            ];
          };

          customCommands = [
            {
              key = "<c-f>";
              context = "localBranches";
              description = "Force push (with lease), requires typing FORCE";
              prompts = [
                {
                  type = "input";
                  key = "Confirm";
                  title = "Type FORCE to rewrite origin/{{.CheckedOutBranch.Name}}";
                  initialValue = "";
                }
              ];
              command = ''[ {{.Form.Confirm | quote}} = "FORCE" ] && git push --force-with-lease origin {{.CheckedOutBranch.Name}} || { echo "Aborted: you must type FORCE (case-sensitive)" >&2; exit 1; }'';
              loadingText = "Force pushing...";
            }
          ];
        };
      };
    };
  };
}
