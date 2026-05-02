{ self, lib, ... }: 

with lib;
let
  name = "development";
in {
  flake.darwinModules.features = self.lib.mkDarwinFeature name ({ ... }: {});

  flake.homeModules.features = self.lib.mkHomeFeature name ({ ... }: {});


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
      programs.java.enable = cfg.configurations.java.enable;
    };
  });

  flake.features.${name} = self.lib.mkFeature name ({ pkgs, cfg, ... }: {
    configurations = {
      docker.enable = mkEnableOption "Whether to enable docker.";
      go.enable = mkEnableOption "Whether to enable the Go programming language.";
      java.enable = mkEnableOption "Whether to enable the Java programming language.";
      rust.enable = mkEnableOption "Whether to enable the Rust programming language.";
      python.enable = mkEnableOption "Whether to enable the Python programming language.";
      node.enable = mkEnableOption "Whether to enable the Web development ecosystem. (Js, Node, ...).";
    };
    config = {
      configurations = {
        docker.enable = mkDefault true;
        go.enable = mkDefault true;
      };

      packages = with pkgs; 
      let 
        goPakcages = if cfg.configurations.go.enable then [
          go
          goperf
        ] else [];
        rustPackages = if cfg.configurations.rust.enable then [
          cargo
          rustc
        ] else [];
        pythonPackages = if cfg.configurations.python.enable then [
          (python3.withPackages (python-pkgs: with python-pkgs; [
            pandas
            requests
          ]))
        ] else [];
        nodejsPackages = if cfg.configurations.node.enable then [
          nodejs
        ] else [];
      in
      goPakcages ++
      rustPackages ++
      pythonPackages ++
      nodejsPackages;
    };
  });
 }
