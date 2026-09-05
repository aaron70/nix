{
  inputs,
  self,
  ...
}: {
  anvil.programs.noctalia = {
    getPackage = self.wrappers.noctalia.wrap;
  };

  flake.wrappers.noctalia = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.wrapperModules.noctalia-shell
    ];

    config = {
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}
