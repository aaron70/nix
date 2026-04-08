{ self, lib, ... }: 

with lib;
let
  name = "development";
in {

  flake.nixosModules.features = self.lib.mkNixosFeature name ({ cfg, config, ... }: {
    config = {
      # NOTE: Be aware of: https://github.com/moby/moby/issues/9976
      # users.users.${config.profile.user.username}.extraGroups = [ "docker" ];
      virtualisation.docker = mkIf cfg.configurations.docker.enable {
        enable = true;
        autoPrune.enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = { };
        };
      };
    };
  });

  flake.features.${name} = self.lib.mkFeature name ({ pkgs, cfg, ... }: {
    configurations = {
      docker.enable = mkEnableOption "Whether to enable docker.";
      go.enable = mkEnableOption "Whether to enable the Go programming language.";
      web.enable = mkEnableOption "Whether to enable the Web development ecosystem. (Js, Node, ...).";
    };
    config = {
      configurations = {
        docker.enable = mkDefault true;
        go.enable = mkDefault true;
        web.enable = mkDefault false;
      };

      packages = with pkgs; 
      let 
        goPakcages = mkIf cfg.configurations.go.enable [
          go
          goperf
        ];
      in
      goPakcages;
    };
  });
 }
