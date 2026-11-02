{
  inputs,
  self,
  lib,
  ...
} @ global:
with lib; {
  anvil.programs.pi = {
    features = ["sops"];
    nixos = {
      host,
      user,
      pkgs,
      config,
      ...
    }: {
      imports = [inputs.pi.nixosModules.default];

      programs.pi.coding-agent = mkIf (user != null) {
        enable = true;
        package = inputs.pi.packages.${pkgs.system}.coding-agent-bun;
        jail.enable = true;
        jail.permissions = combinators:
          with combinators;
            [
              network
              mount-cwd
              wayland

              (with pkgs;
                add-pkg-deps [
                  findutils
                  diffutils
                  gnugrep
                  gawk
                  which
                  jq
                  gnumake
                  python3
                  nix
                  wl-clipboard
                ])

              (try-readonly (noescape config.sops.secrets."api-key/ai/opencode-go/pi-agent".path))
              (try-readonly (noescape "${user.homeDir.nixos}/.config/nvim"))
              (try-readonly (noescape "${user.homeDir.nixos}/.local/share/nvim/site"))
              (try-readwrite (noescape "${user.homeDir.nixos}/worktrees/nix"))
            ]
            ++ (optional (host.metadata ? nixPath) (try-readwrite (noescape host.metadata.nixPath)));
        environment.OPENCODE_API_KEY.file = config.sops.secrets."api-key/ai/opencode-go/pi-agent".path;
        environment.EDITOR.value = getExe (global.config.anvil.programs.editor.getPackage {inherit pkgs;});
        settings = self.dotfiles.pi.default {inherit pkgs;};
        rules = ''
          Never do `git commit`, `git push`, `git ammend` or any other harmful command. Unless you're told to, explicitly.
        '';
      };
    };
  };
}
