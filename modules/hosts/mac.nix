{ inputs, lib, self, ... }: 

let
  host = "mac";
in 
with lib; {
  flake.darwinConfigurations.${host} = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [ self.darwinModules.${host} ];
  };

  flake.darwinModules.${host} = { ... }: {
    imports = [
      self.darwinModules.configurations 
    ];

    config = {
      information = {
        hostname = "mac";
        isLaptop = true;
      };

      preferences = {
        profile = "work";

        programs = {
          terminal.enable = true;
          kitty.enable = true;
          aerospace.enable = true;
        };
      };
    };
  };
}
