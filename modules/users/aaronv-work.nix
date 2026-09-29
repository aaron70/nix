{...}: {
  anvil.users.aaronv-work = {
    name = "aaronv";
    description = "Aaron Vargas";
    metadata = {};
    programs = [
      "editor"
      "terminal"
      "aerospace"
    ];
    features = [
      "homeManager"
      "work-secrets"
    ];
    homeDir.nixos = "/home/aaronv";
    homeDir.darwin = "/Users/aaronv";
    darwin = {
      user,
      config,
      ...
    }: {
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

      anvil.shell.preferences = {
        envVariables = {
          PATH = "/Users/aaronv/go/bin:/opt/homebrew/opt/gradle@8/bin:/opt/homebrew/opt/node@18/bin:$PATH";
          DOCKER_DEFAULT_PLATFORM = "linux/amd64";
          JAVA_HOME = "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home";
          GRADLE_HOME = "/opt/homebrew/Cellar/gradle@8/8.14.3/libexec";
          GRADLE_OPTS = "\"-Dfile.encoding=utf-8\"";
          NVM_DIR = "$HOME/.nvm";
          CD_FZF_EXTRA_PATHS = "/Users/aaronv:3 /Users/aaronv/Documents/repositories:3";

          # LDFLAGS = "-L/opt/homebrew/opt/node@18/lib";
          # CPPFLAGS = "-I/opt/homebrew/opt/node@18/include";
        };

        activationScripts = [
          "export GITHUB_PACKAGE_REGISTRY_USER=$(cat ${config.sops.secrets."github/package/registry/user".path})"
          "export GITHUB_PACKAGE_REGISTRY_API_KEY=$(cat ${config.sops.secrets."github/package/registry/api-key".path})"
        ];
      };
    };
    home = {user, ...}: {
      home.username = user.name;
    };
  };
}
