{self, ...}: {
  anvil.hosts.mac = {
    systems.darwin = {
      "aarch64-darwin" = "mac";
      "x86_64-darwin" = {
        name = "mac-intel";
        pkgs = "nixpkgs-darwin";
      };
    };
    users = {host, ...}: [host.metadata.mainUser];
    features = [];
    programs = [];
    metadata = rec {
      mainUser = "aaronv";
      configurationLimit = 3;
      nixPath = "/Users/${mainUser}/nix";
    };
    darwin = {...}: {};
  };
}