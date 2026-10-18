{
  self,
  lib,
  ...
}:
with lib; let
  common = {...} @ args: {
    imports = [
      (self.lib.inheritPreferences "terminal" args [self.declarations.terminal])
    ];
  };
in {
  anvil.programs.terminal = {
    programs = [
      "shell"
    ];
    nixos = common;
    darwin = common;
  };
}
