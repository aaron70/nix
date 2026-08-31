{...}: {
  anvil.users.aaronv = rec {
    name = "aaronv";
    description = "Aaron Vargas";
    programs = [ ];
    features = [
      "homeManager"
    ];
    homeDir.nixos = "/home/${name}";
    homeDir.darwin = "/Users/${name}";
    nixos = {user, ...}: {
      users.users.${user.name} = {
        inherit description;
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel" "audio"];
        group = user.name;
        home = user.homeDir.nixos;
      };
      users.groups.${user.name} = {};

      virtualisation.vmVariant = {
        users.users.${user.name} = {
          initialPassword = "anvil";
        };
      };
    };
    darwin = {user, ...}: {
      users.users.${user.name} = {
        inherit description;
        # nix-darwin requires a uid; 501 is the macOS first-user uid.
        uid = 501;
        home = user.homeDir.darwin;
        createHome = true;
      };
      users.groups.${user.name} = {};
      # nix-darwin only creates the account on activation when registered.
      users.knownUsers = [user.name];
    };
    home = {user, ...}: {
      home.username = user.name;
    };
  };
}
