{
  self,
  lib,
  ...
}:
with lib; let
  name = "ghostty";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({...}: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({...}: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({...}: {});

  flake.programs.${name} = self.lib.mkProgram name ({...}: {
    configurations = [self.definitions.terminal];
  });

  flake.wrappers.${name} = {config, ...}: {
    imports = [
      self.wrapperModules._ghostty
      (self.lib.mkConfigurationsOption [self.definitions.programs.terminal])
    ];

    config = {
      configuration = ''
        theme=${config.configurations.theme.path}
        command=${getExe config.configurations.shell}
      '';
    };
  };
}
