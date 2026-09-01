{ config, ... }: 
let
  defaultConfiguration = {
      editor = "nvim";
      isTerminalBased = true;
    };
in {
  anvil.programs.editor = {
    metadata = defaultConfiguration;
    getPackage = { metadata, pkgs, ... }: config.anvil.programs.${metadata.editor}.getPackage {inherit pkgs;};
    programs = { program, ... }: [ program.metadata.editor ];
    nixos = { program, pkgs, ... }: with program; {
      environment.variables = {
        EDITOR = getPackage { inherit pkgs metadata;};
      };
    };
    darwin = { program, pkgs, ... }: with program; {
      environment.variables = {
        EDITOR = getPackage { inherit pkgs metadata;};
      };
    };
  };

  flake.wrappers.editor = { wlib, pkgs, ... }: {
    imports = [ wlib.modules.default ];
    config.package = config.anvil.programs.editor.getPackage { inherit pkgs; metadata = defaultConfiguration; };
  };
}
