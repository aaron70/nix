
{ self, lib, ... }: 

with lib;
let
  name = "oh-my-posh";
in
{
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({ ... }: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({ ... }: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ ... }: {});

  flake.programs.${name} = self.lib.mkProgram name ({ ... }: {});

  flake.wrappers.${name} = { pkgs, config, ... }: 
  {
    imports = [ 
      self.wrapperModules._oh-my-posh 
      (self.lib.mkConfigurationsOption [ self.wrapperHelpers.modules.theme ])
    ];
    config = let colors = config.configurations.colors; in {
      extraPackages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
      configuration = self.wrapperHelpers.oh-my-posh.prompts.custom { inherit colors; };
    };
  };
 }
