{
  self,
  lib,
  ...
}:
with lib; let
  commonModule = {
    user,
    program,
    pkgs,
    ...
  }: let
    package = program.getPackage {inherit pkgs;};
  in {
    environment.systemPackages = mkIf (user == null) [package];
    users.users = mkIf (user != null) {
      ${user.name}.packages = [package];
    };
  };
in {
  anvil.programs.kitty = {
    getPackage = self.wrappers.kitty.wrap;
    nixos = commonModule;
    darwin = commonModule;
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
