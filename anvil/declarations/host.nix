{
  self,
  lib,
  ...
}:
with lib; {
  flake.modules.generic.host = {
    imports = [self.modules.generic.entity];
    options = {
      users = mkOption {
        type = types.listOf (types.either types.str (types.submodule {imports = [self.modules.generic.refkey];}));
        default = [];
        description = ''
          Users attached to this host. Each attached user's fragments
          merge into this host's targets of the matching selector,
          evaluated with the user's own context. Hosts with an empty list
          are valid: users are optional and only add per-user fragments.
        '';
      };

      stateVersion = mkOption {
        type = types.str;
        default = "26.11";
        description = ''
          NixOS/home-manager stateVersion, injected into every nixos and
          home target of this host with default priority, so a fragment can
          override it. Darwin targets use `darwinStateVersion` instead
          (nix-darwin's stateVersion is an integer counter, not a release
          string).
        '';
      };

      darwinStateVersion = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Darwin stateVersion, injected into every darwin target of this
          host with default priority, so a fragment can override it.
          nix-darwin's `system.stateVersion` is an integer counter, not a
          release string. When unset, the current max is injected (the
          value nix-darwin recommends for new installations); set an
          integer to pin an older value. The value must not exceed
          nix-darwin's current `system.maxStateVersion`, or evaluation fails with a type error.
        '';
      };

      systems = mkOption {
        type = types.submodule {
          options = {
            nixos = mkOption {
              type = types.nullOr (types.either types.str (types.attrsOf types.str));
              default = null;
              description = ''
                NixOS targets: a system string, or a mapping from system to
                output name for multiple targets. A plain string produces a
                single `nixosConfigurations` named after the host. Required
                (non-null) when the host declares a `nixos` fragment.
              '';
            };

            darwin = mkOption {
              type = types.nullOr (types.either types.str (types.attrsOf types.str));
              default = null;
              description = ''
                Darwin targets: a system string, or a mapping from system to
                output name for multiple targets. A plain string produces a
                single `darwinConfigurations` named after the host. Required
                (non-null) when the host declares a `darwin` fragment.
              '';
            };

            home = mkOption {
              type = types.nullOr (types.either types.str (types.attrsOf types.str));
              default = null;
              description = ''
                Home targets: a system string, or a mapping from system to
                output name for multiple targets. A plain string produces a
                single `homeConfigurations` named after the host. Required
                (non-null) when the host declares a `home` fragment.
              '';
            };
          };
        };
        default = {};
        description = ''
          The system of each target this host produces, keyed by selector.
          Every entry (or the plain string) yields one configuration output
          for that selector, evaluated with the host's fragment of that
          selector.
        '';
      };
    };
  };
}
