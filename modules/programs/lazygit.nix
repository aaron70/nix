{...}: {
  anvil.programs.lazygit = {
    home = {...}: {
      programs.lazygit = {
        enable = true;

        settings = {
          git = {
            # Blocks the built-in "Force push" popup on the normal push key
            disableForcePushing = true;
            # Don't fast-forward other branches on fetch/pull
            autoForwardBranches = "none";
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
