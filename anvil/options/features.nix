{
  self,
  lib,
  ...
}:
with lib; {
  options.anvil.features = mkOption {
    type = types.attrsOf (types.submodule {imports = [self.modules.generic.feature];});
    default = {};
    description = "Features managed by anvil. Each is referenced via its refkey.";
  };
}
