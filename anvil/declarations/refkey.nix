{ lib, ... }:
with lib;
{
  flake.modules.generic.refkey = {
    options = {
      ref = mkOption {
        type = types.str;
        description = "The name of the referencing entity.";
      };

      variant = mkOption {
        type = types.nullOr types.str;
        description = "An optional string referencing a variant name. When set, the entity will use this variant's configuration.";
      };

      override = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = ''
          Free-form attrset that overrides the referenced entity's
          properties; merged with the `merge` field.
        '';
      };

      merge = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = ''
          Free-form attrset merged into the referenced entity's
          configuration; useful to override values.
        '';
      };
    };
  };
}
