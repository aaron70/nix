{lib, ...}: {
  options.flake.declarations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Anvil's declarations";
  };
}
