{
  self,
  lib,
  ...
}:
with lib; let
  refKeyListType = types.listOf (types.either types.str (types.submodule {imports = [self.modules.generic.refkey];}));
in {
  flake.modules.generic.entity = {
    imports = [self.modules.generic.fragments];
    options = {
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Host name. Defaults to the attribute name when unset.";
      };

      metadata = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = ''
          Free-form attrSet metadata, any fields. Accessible from this
          entity's fragments via the context (e.g. `host.metadata` or
          `user.metadata`).
        '';
      };

      features = mkOption {
        type = types.either (types.functionTo refKeyListType) refKeyListType;
        default = [];
        description = ''
          A list of features to enable on the entity. Each item can be a string
          feature name or a refkey submodule reference.
        '';
      };

      programs = mkOption {
        type = types.either (types.functionTo refKeyListType) refKeyListType;
        default = [];
        description = ''
          A list of programs to enable on the entity. Each item can be a string
          program name or a refkey submodule reference.
        '';
      };
    };
  };
}
