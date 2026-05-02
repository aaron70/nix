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
