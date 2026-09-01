{inputs, ...}: {
  anvil.features.sops = let
    commonModule = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [age sops];
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
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
