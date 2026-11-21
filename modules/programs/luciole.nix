{inputs, ...}: {
  anvil.programs.luciole = {
    nixos = {...}: {
      imports = [inputs.luciole.nixosModules.default];

      programs.luciole.enable = true;
      services.gvfs.enable = true;
    };
  };
}
