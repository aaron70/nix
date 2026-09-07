{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.kitty = rec {
    getPackage = self.wrappers.kitty.wrap;
    nixos = {
      user,
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      imports = [
        (self.lib.installPackages user [package])
      ];
    };
    darwin = nixos;
  };

  flake.wrappers.kitty = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.wrapperModules.kitty
    ];

    config = {
      settings = {
        include = "${pkgs.vimPlugins.tokyonight-nvim}/extras/kitty/tokyonight_moon.conf";
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        font_family = "JetBrainsMono Nerd Font";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
      };
    };
  };
}
