{ inputs, self, lib, ... }: 

let
  host = "mac";
in {
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.darwinModules.${host} ];
  };

  flake.darwinModules.${host} = { ... }: {
    imports = [
      self.darwinModules.configurations 
    ];

    config = {
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      information = {
        hostname = "mac";
        isLaptop = true;
      };
      preferences = {
        profile = "work";

        programs = {
          desktop.enable = false;
          terminal.enable = true;
          shell.enable = true;
        };
      };
    };
  };
}
