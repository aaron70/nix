{
  self,
  lib,
  ...
}:
with lib; let
  name = "aerospace";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({...}: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({
    cfg,
    pkgs,
    ...
  }: {
    config = {
      programs.aerospace.enable = true;
      xdg.configFile."aerospace/aerospace.toml".text = readFile ./dotfiles/aerospace.toml;
    };
  });

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({...}: {});

  flake.programs.${name} = self.lib.mkProgram name ({pkgs, ...}: {
    configurations = [];
    config = {
      package = pkgs.aerospace;
    };
  });

  # flake.wrappers.${name} = { config, ... }: {
  #   imports = [
  #     self.wrapperModules._kitty
  #     (self.lib.mkConfigurationsOption [ self.definitions.programs.terminal ])
  #   ];
  #
  #   config = {
  #     configuration = ''
  #       include ${config.configurations.theme.path}
  #       confirm_os_window_close 0
  #       enable_audio_bell false
  #       font_family      JetBrainsMono Nerd Font
  #       bold_font        auto
  #       italic_font      auto
  #       bold_italic_font auto
  #
  #       shell ${getExe config.configurations.shell}
  #     '';
  #   };
  # };
}
