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
}
