{
  inputs,
  self,
  lib,
  config,
  ...
} @ global:
with lib; {
  anvil.programs.pi = {
    features = ["sops"];
    nixos = {
      pkgs,
      user,
      config,
      ...
    }: {
      imports = [inputs.pi.nixosModules.default];

      programs.pi.coding-agent = mkIf (user != null) {
        enable = true;
        package = inputs.pi.packages.${pkgs.system}.coding-agent-bun;
        jail.enable = true;
        jail.permissions = combinators:
          with combinators; [
            network
            mount-cwd

            (add-pkg-deps [
              pkgs.findutils
              pkgs.diffutils
              pkgs.gnugrep
              pkgs.gawk
              pkgs.which
              pkgs.jq
              pkgs.gnumake
              pkgs.python3
              pkgs.nix
            ])

            (try-readonly (noescape config.sops.secrets."api-key/ai/opencode-go/pi-agent".path))
          ];
        environment.OPENCODE_API_KEY.file = config.sops.secrets."api-key/ai/opencode-go/pi-agent".path;
        environment.EDITOR.value = getExe (global.config.anvil.programs.editor.getPackage {inherit pkgs;});
        settings = self.dotfiles.pi.default {};
        rules = ''
          Never do `git commit`, `git push`, `git ammend` or any other harmful command. Unless you're told to, explicitly.
        '';
      };
    };
  };
}
