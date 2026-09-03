{
  self,
  lib,
  ...
}:
with lib; {
  flake.modules.generic.variants = {
    options = {
      variants = mkOption {
        type = types.attrsOf (types.submodule {imports = [self.modules.generic.entity];});
        default = {};
        description = ''
          A set of variant modules, each accepting options similar to entity options.
          Used to define multiple variant configurations for a flake.
        '';
      };
    };
  };
}
