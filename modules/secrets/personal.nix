{
  inputs,
  lib,
  ...
}:
with lib; {
  anvil.features.personal-secrets = let
    mkIfUser = user: mkIf (user != null);
    commonModule = {user, ...}: {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
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
    nixos = commonModule;
    darwin = commonModule;
  };
}
