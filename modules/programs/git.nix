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
      environment.systemPackages = [package];

      sops.templates."gitconfig-personal" = {
        content = ''
          [user]
              email = ${config.sops.placeholder."email"}
        '';
        owner = mkIf (user != null) user.name; # so your user can actually read the rendered file
      };
    };
  };

  flake.wrappers.git = {wlib, ...}: {
    imports = [
      wlib.wrapperModules.git
    ];

    settings = {
      init.defaultBranch = "main";

      core = {
        autocrlf = false;
      };

      pull.rebase = true;
      push.autoSetupRemote = true;

      # subsection example -> becomes url."https://github.com/" { insteadOf = "gh:"; }
      url."https://github.com/".insteadOf = "gh:";
    };
  };
}
