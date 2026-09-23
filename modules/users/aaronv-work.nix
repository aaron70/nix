{...}: {
  anvil.users.aaronv-work = {
    name = "aaronv";
    description = "Aaron Vargas";
    metadata = {};
    programs = [
      "editor"
      "terminal"
      "desktop"
    ];
    features = [
      "homeManager"
      "work-secrets"
    ];
    homeDir.nixos = "/home/aaronv";
    homeDir.darwin = "/Users/aaronv";
    darwin = {user, ...}: {
      users.users.${user.name} = {
        description = user.description;
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
