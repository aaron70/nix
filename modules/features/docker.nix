{lib, ...}:
with lib; {
  anvil.features.docker = {
    nixos = {
      user,
      pkgs,
      ...
    }: {
      # Docker ships its zsh completion (_docker) in site-functions.
      anvil.shell.preferences.activationScripts = [
        "fpath=(${pkgs.docker}/share/zsh/site-functions $fpath)"
      ];

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
