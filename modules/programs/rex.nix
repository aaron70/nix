{
  inputs,
  self,
  ...
}: {
  anvil.programs.rex = {
    nixos = {user, ...}: {
      imports = [
        inputs.rex.nixosModules.default
        (self.lib.forUser user {
          ${user.name}.extraGroups = ["rex"];
        })
      ];
      services.rex.enable = true;
    };
  };
}
