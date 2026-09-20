{
  self,
  lib,
  ...
}:
with lib; {
  options.anvil.users = mkOption {
    type = types.attrsOf (types.submodule {imports = [self.modules.generic.user];});
    default = {};
    description = "Users managed by anvil. Each is referenced by hosts via its refkey; its fragments merge into the targets of attaching hosts.";
  };
}
