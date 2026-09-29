{
  self,
  lib,
  ...
}:
with lib; {
  flake.modules.generic.program = {
    imports = [
      self.modules.generic.entity
      self.modules.generic.variants
    ];

    options = {
      getPackage = mkOption {
        type = types.functionTo types.package;
        description = ''
          Function producing this program's package. Takes free-form arguments
          (e.g. `{pkgs, ...}`) and returns the package to install.
        '';
      };
    };
  };
}
