{self, ...}: let
  common = {
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
in {
  anvil.programs.discord = {
    getPackage = {pkgs, ...}: pkgs.vesktop;
    nixos = common;
    darwin = common;
  };
}
