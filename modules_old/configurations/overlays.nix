{lib, ...}:
with lib; {
  flake.nixosModules.configurations = {config, ...}: {
    config = {
      nixpkgs.overlays = [
      ];
    };
  };
}
