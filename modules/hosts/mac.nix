{
  self,
  lib,
  ...
}:
with lib; {
  anvil.hosts.mac = {
    systems.darwin = "aarch64-darwin";
    users = {host, ...}: [host.metadata.mainUser];
    features = [
      "configurations"
    ];
    programs = [];
    metadata = rec {
      mainUser = "aaronv-work";
      configurationLimit = 3;
      nixPath = "/Users/${mainUser}/nix";
    };
    darwin = {...}: {
    };
  };
}
