{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
  flake.nixosModules.configurations = {config, ...}: {
    imports = [inputs.home-manager.nixosModules.default];

    config = {
      home-manager.users.${config.profile.user.username} = {...}: {
        imports = [
          self.homeModules.configurations
          self.homeModules.profile
          self.homeModules.programs
          self.homeModules.features
        ];
        config = {
          preferences.profile = mkDefault config.preferences.profile;
          preferences.programs = mkDefault config.preferences.programs;
          programs.home-manager.enable = true;
          home = {
            username = config.profile.user.username;
            homeDirectory = mkDefault "/home/${config.profile.user.username}";
            stateVersion = config.preferences.stateVersion;

            file.".XCompose".text = ''
              include "%L"

              # Acute accents (mimics macOS Option+e then vowel)
              <Multi_key> <e> <a> : "á"
              <Multi_key> <e> <e> : "é"
              <Multi_key> <e> <i> : "í"
              <Multi_key> <e> <o> : "ó"
              <Multi_key> <e> <u> : "ú"
              <Multi_key> <e> <A> : "Á"
              <Multi_key> <e> <E> : "É"
              <Multi_key> <e> <I> : "Í"
              <Multi_key> <e> <O> : "Ó"
              <Multi_key> <e> <U> : "Ú"

              # Tilde (mimics macOS Option+n then n)
              <Multi_key> <n> <n> : "ñ"
              <Multi_key> <n> <N> : "Ñ"

              # Diaeresis
              <Multi_key> <u> <u> : "ü"
              <Multi_key> <u> <U> : "Ü"

              # Inverted punctuation
              <Multi_key> <exclam> <exclam> : "¡"
              <Multi_key> <question> <question> : "¿"
            '';
          };
        };
      };
    };
  };

  flake.darwinModules.configurations = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.home-manager.darwinModules.home-manager];

    config = {
      home-manager.users.${config.profile.user.username} = {...}: {
        imports = [
          inputs.mac-app-util.homeManagerModules.default
          self.homeModules.configurations
          self.homeModules.profile
          self.homeModules.programs
          self.homeModules.features
        ];
        config = {
          preferences.profile = mkDefault config.preferences.profile;
          preferences.programs = mkDefault config.preferences.programs;
          programs.home-manager.enable = true;
          home = {
            username = config.profile.user.username;
            homeDirectory = mkDefault /Users/${config.profile.user.username};
            stateVersion = config.preferences.stateVersion;
          };
        };
      };
    };
  };
}
