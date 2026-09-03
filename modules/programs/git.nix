{
  self,
  lib,
  ...
}:
with lib; {
  anvil.programs.git = {
    features = ["sops"];
    getPackage = {
      pkgs,
      config,
      ...
    }:
      self.wrappers.git.wrap {
        inherit pkgs;
        settings.include = {path = config.sops.templates."gitconfig-personal".path;};
      };

    nixos = {
      user,
      program,
      config,
      pkgs,
      ...
    }: let
      package = program.getPackage {inherit pkgs config;};
    in {
      environment.systemPackages = with pkgs; [
        package
        lazygit
        gh
      ];

      sops.templates."gitconfig-personal" = mkIf (user != null) {
        content = ''
          [user]
              name = ${user.name}
              email = ${user.metadata.email}
        '';
        owner = user.name; # so your user can actually read the rendered file
      };
    };
  };

  flake.wrappers.git = {
    wlib,
    pkgs,
    ...
  }: {
    imports = [
      wlib.wrapperModules.git
    ];

    settings = {
      init.defaultBranch = "main";

      core = {
        autocrlf = false;
      };

      credential."https://github.com".helper = ["" "!${pkgs.gh}/bin/gh auth git-credential"];
      credential."https://gist.github.com".helper = ["" "!${pkgs.gh}/bin/gh auth git-credential"];

      pull.rebase = true;
      push.autoSetupRemote = true;

      # subsection example -> becomes url."https://github.com/" { insteadOf = "gh:"; }
      url."https://github.com/".insteadOf = "gh:";
    };
  };
}
