{
  self,
  config,
  lib,
  ...
}:
with lib; let
  anvilUsers = config.anvil.users;
in {
  flake.lib.getUser = host: name:
    if anvilUsers ? "${name}"
    then let
        user = anvilUsers.${name};
        userName = self.lib.getPropertyOrDefault user "name" name;
      in
        if user.name == null
        then user // {name = userName;}
        else user
    else throw "Anvil: Host '${self.lib.getPropertyOrDefault host "name" "<unknown-host>"}' declares a not found user '${name}'. Did you forget to set anvil.users.${name}?";

  flake.lib.getUsersList = entity: ctx: if isFunction entity.users then entity.users ctx else entity.users;

  flake.lib.getUserModules = platform: host: user: let
    ctx = {inherit host user;};
    childrenPrograms =  self.lib.getProgramsList user ctx;
    childrenFeatures =  self.lib.getFeaturesList user ctx;
    acc =
      self.lib.getProgramsModules
      (self.lib.getFeaturesModules {} platform "User" user ctx childrenFeatures)
      platform "User" user ctx childrenPrograms;
  in
    (optional (user.${platform} != null) (self.lib.withContext ctx user.${platform}))
    ++ attrValues acc.features
    ++ attrValues acc.programs;

  flake.lib.getUsersModules = platform: host: users:
    concatMap
    (
      userName: let
        user = self.lib.resolveRefKey userName (self.lib.getUser host);
      in
        self.lib.getUserModules platform host user
    )
    users;
}
