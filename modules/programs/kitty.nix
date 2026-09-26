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
    darwin = {
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      imports = [
        (self.lib.installPackages null [package]) # Darwin requires to be installed globally to create the kitty.app
      ];
    };
  };

  flake.wrappers.kitty = {
    wlib,
    pkgs,
    config,
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

      wrapperImplementation = mkIf pkgs.stdenv.hostPlatform.isDarwin "binary";
      buildCommand.kittyAppBundle = mkIf pkgs.stdenv.hostPlatform.isDarwin {
        after = [
          "symlinkScript"
          "makeWrapper"
        ];
        data = ''
          bundleExe=${placeholder config.outputName}/Applications/kitty.app/Contents/MacOS/kitty
          # `lndir` leaves this as a symlink to the original package's binary.
          rm -f "$bundleExe"
          cp ${config.wrapperPaths.placeholder} "$bundleExe"
        '';
      };
    };
  };
}
