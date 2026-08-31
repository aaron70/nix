{
  self,
  lib,
  ...
}:
with lib; {
  options.anvil.programs = mkOption {
    type = types.attrsOf (types.submodule {imports = [self.modules.generic.program];});
    default = {};
    description = "Programs managed by anvil. Each is referenced via its refkey.";
  };
}
