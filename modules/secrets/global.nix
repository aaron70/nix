{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
  anvil.features.global-secrets = let
    commonModule = {...}: {
      sops = {
        secrets = {
          "wifi/home/ssid" = {sopsFile = ./global.yaml;};
          "wifi/home/ssid_5g" = {sopsFile = ./global.yaml;};
          "wifi/home/psk" = {sopsFile = ./global.yaml;};
          "wifi/hotspot/ssid" = {sopsFile = ./global.yaml;};
          "wifi/hotspot/psk" = {sopsFile = ./global.yaml;};
        };
      };
    };
  in {
    features = ["sops"];
    nixos = {user, ...}: let
      ctx = {inherit user;};
    in {
      imports = [
        inputs.sops-nix.nixosModules.sops
        (self.lib.withContext ctx commonModule)
      ];
    };
    darwin = {user, ...}: let
      ctx = {inherit user;};
    in {
      imports = [
        inputs.sops-nix.darwinModules.sops
        (self.lib.withContext ctx commonModule)
      ];
    };
  };
}
