{...}: {
  anvil.hosts.mac = {
    systems.darwin = "aarch64-darwin";
    users = ["aaronv-work"];
    features = ["configurations"];
    programs = [];
    metadata = rec {
      mainUser = "aaronv";
      configurationLimit = 3;
      nixPath = "/Users/${mainUser}/nix";
    };
    darwin = {...}: {
    };
  };
}
