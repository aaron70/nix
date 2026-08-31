{lib, ...}:
with lib; {
  flake.modules.generic.fragments = {
    options = {
      nixos = mkOption {
        type = types.nullOr types.deferredModule;
        default = null;
        description = ''
          NixOS fragment for this entity. `null` when unset; merged into
          the targets that enable it.
        '';
      };

      darwin = mkOption {
        type = types.nullOr types.deferredModule;
        default = null;
        description = ''
          Darwin fragment for this entity. `null` when unset; merged into
          the targets that enable it.
        '';
      };

      home = mkOption {
        type = types.nullOr types.deferredModule;
        default = null;
        description = ''
          Home fragment for this entity. `null` when unset; merged into
          the targets that enable it.
        '';
      };
    };
  };
}
