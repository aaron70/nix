{lib, ...}:
with lib; let
  mappedBranches = ''
    {
      "main": " main",
      "main/*": " ",
      "develop": " develop",
      "develop/*": " ",
      "feature/*": " ",
      "feat/*": " ",
      "bug/*": " ",
      "poc/*": "󰙨 "
    }
  '';
in {
  flake.dotfiles.oh-my-posh.theme = {
    colors,
    pathStyle,
    promptGlyph,
    powerline,
    upstreamIcon,
    osIcon,
    ...
  }: let
    pathSegment = ''
      {
        "type": "path",
        "style": "plain",
        "background": "transparent",
        "foreground": "${colors.base0D}",
        "template": "${ if pathStyle == "folder" then " {{ .Path }} " else "{{ .Path }} "
      }",
        "options": {
          "style": "${pathStyle}"
        }
      },
    '';

    upstreamSegment = optionalString upstreamIcon ''
      {
        "type": "git",
        "style": "plain",
        "foreground": "${colors.base07}",
        "background": "transparent",
        "github_icon": " ",
        "gitlab_icon": " ",
        "bitbucket_icon": " ",
        "template": "{{ .UpstreamIcon }}  at ",
        "properties": {
          "fetch_upstream_icon": true
        }
      },
    '';

    gitSegment =
      if powerline
      then ''
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "",
          "leading_powerline_symbol": "",
          "foreground": "transparent",
          "background": "${colors.base07}",
          "template": "{{ .HEAD }}{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}",
          "properties": {
            "branch_icon": "",
            "fetch_status": true,
            "mapped_branches": ${mappedBranches}
          }
        }
      ''
      else ''
        {
          "type": "git",
          "style": "plain",
          "powerline_symbol": "",
          "leading_powerline_symbol": "",
          "foreground": "${colors.base07}",
          "background": "transparent",
          "template": "{{ .HEAD }}{{ if gt .Behind 0 }}+{{ end }}{{ if gt .Ahead 0 }}-{{ end }}",
          "properties": {
            "branch_icon": "",
            "fetch_status": true,
            "mapped_branches": ${mappedBranches}
          }
        }
      '';

    promptSegment =
      if osIcon
      then ''
        {
          "type": "os",
          "style": "plain",
          "foreground_templates": [
            "{{if gt .Code 0}}${colors.base08}{{end}}",
            "{{if le .Code 0}}${colors.base0C}{{end}}"
          ],
          "background": "transparent",
          "template": "{{.Icon}} "
        }
      ''
      else ''
        {
          "type": "text",
          "style": "plain",
          "foreground_templates": [
            "{{if gt .Code 0}}${colors.base08}{{end}}",
            "{{if le .Code 0}}${colors.base0C}{{end}}"
          ],
          "background": "transparent",
          "template": "${promptGlyph}"
        }
      '';
  in ''
    {
      "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
      "final_space": true,
      "console_title_template": "{{ .Shell }} in {{ .Folder }}",
      "version": 4,
      "blocks": [
        {
          "type": "prompt",
          "alignment": "left",
          "overflow": "hide",
          "segments": [
            ${pathSegment}
            ${upstreamSegment}
            ${gitSegment}
          ]
        },
        {
          "type": "prompt",
          "alignment": "right",
          "overflow": "hide",
          "segments": [
            {
              "type": "executiontime",
              "style": "plain",
              "foreground_templates": [
                "{{if gt .Code 0}}${colors.base08}{{else}}${colors.base0B}{{end}}"
              ],
              "template": " {{ .FormattedMs }}",
              "options": {
                "threshold": 1000,
                "style": "austin"
              }
            }
          ]
        },
        {
          "type": "prompt",
          "alignment": "left",
          "newline": true,
          "segments": [
            ${promptSegment}
          ]
        }
      ],
      "transient_prompt": {
        "foreground": "${colors.base0D}",
        "background": "transparent",
        "template": "${promptGlyph}"
      },
      "secondary_prompt": {
        "foreground": "${colors.base0D}",
        "background": "transparent",
        "template": "${promptGlyph}"
      }
    }
  '';
}
