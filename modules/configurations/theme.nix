{ lib, ... }:

with lib;
{

  flake.homeModules.configurations = { pkgs, ... }: let
    cursor_theme_name = "BreezeX-RosePine-Linux";
  in {
    config.home = mkIf pkgs.stdenv.isLinux {
      packages = with pkgs; [ rose-pine-cursor ];
      sessionVariables = {
        XCURSOR_THEME = cursor_theme_name;
        XCURSOR_SIZE = "25";
      };      
      pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        # package = pkgs.bibata-cursors;
        # name = "Bibata-Modern-Classic";
        package = pkgs.rose-pine-cursor;
        name = cursor_theme_name;
        size = 25;
      };
    };
  };

}
