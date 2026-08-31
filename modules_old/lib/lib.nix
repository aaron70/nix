{
  inputs,
  lib,
  ...
}:
with lib; {
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      lib = inputs.nixpkgs.lib.mkOption {
        default = {};
      };
    };
  };

  config.flake.lib = {
    resourcesPath = ../../resources;
  };
}
