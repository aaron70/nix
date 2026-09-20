{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
  anvil.features.personal-secrets = let
    mkIfUser = user: mkIf (user != null);
    commonModule = {user, ...}: {
      sops = {
        defaultSopsFile = ./personal.yaml;
        secrets = {
          "email" = {owner = mkIfUser user user.name;};
          "password" = {owner = mkIfUser user user.name;};
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
