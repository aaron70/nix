{...}: {
  anvil.users.aaronv = {
    name = "aaronv";
    description = "Aaron Vargas";
    metadata = {
      email = "41397746+aaron70@users.noreply.github.com";
    };
    programs = [
      "editor"
      "terminal"
      "desktop"
    ];
    features = [
      "homeManager"
      "personal-secrets"
    ];
    homeDir.nixos = "/home/aaronv";
    homeDir.darwin = "/Users/aaronv";
    nixos = {user, config, ...}: {
      users.users.${user.name} = {
        description = user.description;
        uid = 1000;
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel" "audio"];
        group = user.name;
        home = user.homeDir.nixos;
        hashedPasswordFile = config.sops.secrets."password".path;
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
