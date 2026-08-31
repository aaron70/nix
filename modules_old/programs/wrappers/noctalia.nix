{
  inputs,
  self,
  ...
}: let
  name = "noctalia";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({...}: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({...}: {
    config = {
      # TODO: Look if this configuration can be applied trough the wrapper using Noctalia v5
      xdg.configFile."noctalia/config.toml".text = self.wrapperHelpers.noctalia.config.default {};
    };
  });

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({...}: {
    config = {
      environment.variables = {
        __NV_PRIME_RENDER_OFFLOAD = 0;
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
      };
    };
  });

  flake.programs.${name} = self.lib.mkProgram name ({...}: {});

  flake.wrappers.${name} = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      (self.lib.mkConfigurationsOption [])
      wlib.wrapperModules.noctalia-shell
    ];

    config = {
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      runtimePkgs = with pkgs; [
        # Dependencies for https://noctalia.dev/plugins/official/screen_recorder
        gpu-screen-recorder
        xdg-desktop-portal
        xdg-desktop-portal-gnome
      ];
    };
  };
}
