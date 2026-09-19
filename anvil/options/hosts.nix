{
  self,
  lib,
  config,
  ...
}:
with lib; {
  options.anvil.hosts = mkOption {
    type = types.attrsOf (types.submodule {imports = [self.modules.generic.host];});
    default = {};
    description = "Hosts managed by anvil. Each produces configurations for whichever fragments are set.";
  };

  config.flake.nixosConfigurations = self.lib.mkHosts "nixos" self.lib.mkNixosConfiguration;
  config.flake.darwinConfigurations = self.lib.mkHosts "darwin" self.lib.mkDarwinConfiguration;
  config.flake.homeConfigurations = self.lib.mkHosts "home" self.lib.mkHomeConfiguration;
  config.flake.checks =
    foldl'
    (acc: platform: acc // (self.lib.mkHostChecks platform.platform platform.configurations platform.mkCheck platform.suffix))
    {}
    [
      {
        platform = "nixos";
        configurations = config.flake.nixosConfigurations;
        mkCheck = c: c.config.system.build.toplevel;
        suffix = "";
      }
      {
        platform = "darwin";
        configurations = config.flake.darwinConfigurations;
        mkCheck = c: c.config.system.build.toplevel;
        suffix = "-darwin";
      }
      {
        platform = "home";
        configurations = config.flake.homeConfigurations;
        mkCheck = c: c.activationPackage;
        suffix = "-home";
      }
    ];
}
