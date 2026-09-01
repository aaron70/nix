{ inputs, self, lib, ... }:
with lib;
{
  anvil.programs.nvim = {
    getPackage = { pkgs, ... }: self.wrappers.nvim.wrap { inherit pkgs; };
    nixos = {user, program, pkgs, ...}: let
      package = program.getPackage { inherit pkgs; };
    in {
      environment.systemPackages = mkIf (user == null) [ package ];
      users.users.${user.name}.packages = mkIf (user != null) [ package ];
    };
    darwin = {user, program, pkgs, ...}: let
      package = program.getPackage { inherit pkgs; };
    in {
      environment.systemPackages = mkIf (user == null) [ package ];
      users.users.${user.name}.packages = mkIf (user != null) [ package ];
    };
  };

  flake.wrappers.nvim = { wlib, pkgs, ... }: {
    imports = [ wlib.modules.default ];
    config.package = inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  flake.wrappers.nvim-unwrapped = { wlib, pkgs, ... }: {
    imports = [ wlib.modules.default ];
    config.package = inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
