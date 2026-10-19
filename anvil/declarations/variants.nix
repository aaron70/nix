{
  self,
  lib,
  ...
}:
with lib; {
  flake.modules.generic.variants = {
    options = {
      variants = mkOption {
        type = types.attrsOf (types.submodule {
          imports = [self.modules.generic.entity];
          options.getPackage = mkOption {
            type = types.functionTo types.package;
            description = ''
              Function producing this program's package. Takes free-form arguments
              (e.g. `{pkgs, ...}`) and returns the package to install.
            '';
          };
        });
        default = {};
        description = ''
          A set of variant modules, each accepting options similar to entity options.
          Used to define multiple variant configurations for a flake.
        '';
      };
    };
  };
}
