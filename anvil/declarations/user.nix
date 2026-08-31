{
  self,
  lib,
  ...
}:
with lib; {
  flake.modules.generic.user = {
    imports = [self.modules.generic.entity];
    options = {
      description = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Human-readable description of the user.";
      };

      homeDir.nixos = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The home directory path of the user for linux modules";
      };

      homeDir.darwin = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The home directory path of the user for darwin modules";
      };
    };
  };
}
