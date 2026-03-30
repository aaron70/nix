{ lib, ... }: 

with lib;
{

  flake.nixosModules.configurations = { config, ... }: {
    config = {

      users.users.${config.profile.user.username} = {
        isNormalUser = true;
        description = config.profile.user.fullname;
        extraGroups = [ "networkmanager" "wheel" "audio" ];
        group = config.profile.user.username;
      };
      users.groups.${config.profile.user.username} = {};

      virtualisation.vmVariant = {
        users.users.${config.profile.user.username} = {
          isNormalUser = true;
          description = config.profile.user.fullname;
          extraGroups = [ "networkmanager" "wheel" "audio" ];
          group = config.profile.user.username;
          initialPassword = "test";
        };
        users.groups.${config.profile.user.username} = {};
      };
    };
  };

}
