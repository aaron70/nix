{lib, ...}: {
  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Anvil's helper library, exposed as the flake output `lib`.";
  };
}
