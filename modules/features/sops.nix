{inputs, ...}: {
  anvil.features.sops = let
    commonModule = {pkgs, ...}: let
      ageKeyPath = "/var/lib/sops-nix/key.txt";
    in {
      environment.variables.SOPS_AGE_KEY_FILE = ageKeyPath;
      environment.systemPackages = with pkgs; [age sops];
      sops.age.keyFile = ageKeyPath;
      sops.age.generateKey = true;
    };
  in {
    nixos = {...}: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        commonModule
      ];
    };
    darwin = {...}: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        commonModule
      ];
    };
  };
}
