{lib, ...}:
with lib; {
  anvil.features.docker = {
    nixos = {user, ...}: {
      # NOTE: Be aware of: https://github.com/moby/moby/issues/9976
      # users.users = mkIf (user != null) {
      #   ${user.name}.extraGroups = [ "docker" ];
      # };
      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {};
        };
      };
    };
  };
}
