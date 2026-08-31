{
  self,
  lib,
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
}
