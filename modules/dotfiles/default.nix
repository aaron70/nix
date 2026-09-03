{lib, ...}: {
  options.flake.dotfiles = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
    description = "Anvil's helper library for managing dotfiles, exposed as the flake output `dotfiles`.";
  };
}
