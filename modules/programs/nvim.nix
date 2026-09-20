{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.nvim = rec {
    getPackage = {pkgs, ...}: self.wrappers.nvim.wrap {inherit pkgs;};
    nixos = {
      user,
      program,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs;};
    in {
      imports = [
        (self.lib.installPackages user [package])
      ];
    };
    darwin = nixos;
  };

  flake.wrappers.nvim = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];
    config.package = inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  flake.wrappers.nvim-unwrapped = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];
    config.package = inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
