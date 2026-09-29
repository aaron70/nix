{
  self,
  lib,
  ...
}:
with lib; {
  flake.lib.installPackages = user: packages: ({...}: {
    imports = [
      (self.lib.forUser user {
        ${user.name}.packages = packages;
      })
    ];
    environment.systemPackages = mkIf (user == null) packages;
  });

  flake.lib.forUser = user: attrSet: ({...}: {
    users.users = mkIf (user != null) attrSet;
  });

  flake.lib.inheritPreferences = name: args: preferences: {
    options = {
      anvil.${name}.preferences = mkOption {
        type = types.submodule {
          _module.args = args;
          imports = preferences;
        };
      };
    };
  };

  flake.lib.usePreferences = name: options: {
    imports = options.anvil.${name}.preferences.definitions;
  };
}
