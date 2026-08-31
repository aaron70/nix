{
  self,
  lib,
  ...
}:
with lib; {
  flake.modules.generic.feature = {
    imports = [
      self.modules.generic.entity
      self.modules.generic.variants
    ];
  };
}
