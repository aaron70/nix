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
      (self.lib.installPackages user [
        package
        (pkgs.writeShellScriptBin "toggle-herdr-popup" (self.dotfiles.herdr.scripts.toggle-herdr-popup {}))
      ])
    ];
  };
in {
  anvil.programs.herdr = {
    getPackage = {pkgs, ...}: self.wrappers.herdr.wrap {inherit pkgs;};
    home = {...}: {
      xdg.configFile."herdr/config.toml".text = self.dotfiles.herdr.default {};
    };
    nixos = common;
    darwin = common;
  };

  flake.wrappers.herdr = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.default
    ];

    config = {
      package = pkgs.herdr;
    };
  };
}
