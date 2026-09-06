{
  inputs,
  self,
  ...
}: {
  anvil.programs.noctalia = {
    getPackage = self.wrappers.noctalia.wrap;
    nixos = { ... }: {
      environment.variables = {
        __NV_PRIME_RENDER_OFFLOAD = 0;
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
      };
    };
    home = { pkgs, ... }: {
      # TODO: Look if this configuration can be applied trough the wrapper using Noctalia v5
      xdg.configFile."noctalia/config.toml".text = self.dotfiles.noctalia.default {};
      home.packages = with pkgs; [ cowsay ];
    };
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
      runtimePkgs = with pkgs; [
        # Dependencies for https://noctalia.dev/plugins/official/screen_recorder
        gpu-screen-recorder
        xdg-desktop-portal
        xdg-desktop-portal-gnome
      ];
    };
  };
}
