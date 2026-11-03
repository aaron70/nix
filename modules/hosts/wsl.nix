{
  inputs,
  lib,
  ...
}:
with lib; {
  anvil.hosts.wsl = {
    systems.nixos = "x86_64-linux";
    users = {host, ...}: [host.metadata.mainUser];
    features = [];
    programs = [];
    metadata = rec {
      mainUser = "aaronv";
      configurationLimit = 3;
      nixPath = "/home/${mainUser}/nix";
    };
    nixos = {host, ...}: {
      imports = [inputs.nixos-wsl.nixosModules.default];

      networking.hostName = "${host.metadata.mainUser}-${host.name}";

      wsl = {
        enable = true;
        defaultUser = host.metadata.mainUser;
        startMenuLaunchers = true;
      };

      nixpkgs.config.allowUnfree = true;
      nixpkgs.hostPlatform = mkDefault "x86_64-linux";
    };
  };
}
