{
  self,
  lib,
  ...
}: let
  hexColor =
    lib.types.strMatching "^#[0-9a-fA-F]{6}$"
    // {
      description = "6-digit hex color (including '#')";
    };

  base16Slots = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
in
  with lib; {
    flake.modules.generic.colors = _: {
      options = {
        preferences.theme.colors = mkOption {
          type = types.submodule {
            options = genAttrs base16Slots (
              slot:
                mkOption {
                  type = hexColor;
                  example = "#1a1b26";
                  description = "Base16 slot ${slot}.";
                }
            );
          };
          description = "A complete Base16 color scheme (base00–base0F as 6-digit hex strings with '#').";
          default = self.lib.getColors;
        };
      };
    };

    flake.lib.getColors = let
      theme = builtins.fromJSON (builtins.readFile "${self.dotfiles.resourcesPath}/themes/tokyo-night-moon.json");
    in
      theme.palette;
  }
