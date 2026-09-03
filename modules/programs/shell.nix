{
  self,
  config,
  lib,
  ...
} @ global:
with lib; let
  defaultConfiguration = {
    shell.name = "zsh";
    shell.multiplexer.name = "tmux";
    shell.prompt.name = "oh-my-posh";
    shell.editor.name = global.config.anvil.programs.editor.metadata.editor;
  };
  commonModule = {
    host,
    program,
    user,
    pkgs,
    config,
    ...
  } @ args: {
    fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
    users.users = mkIf (user != null) {
      ${user.name} = {
        shell = with program; getPackage args;
      };
    };
  };
in {
  anvil.programs.shell = {
    metadata = defaultConfiguration;
    getPackage = {
      host,
      pkgs,
      program,
      config,
      ...
    }:
      with program.metadata;
        global.config.anvil.programs.${shell.name}.getPackage rec {
          imports = [
            (self.dotfiles.shell.getConfiguration {inherit defaultConfiguration;})
          ];

          inherit pkgs;
          prompt.name = shell.prompt.name;
          prompt.getPackage = mkForce global.config.anvil.programs.${prompt.name}.getPackage;

          multiplexer.name = shell.multiplexer.name;
          multiplexer.getPackage = mkForce global.config.anvil.programs.${multiplexer.name}.getPackage;

          metadata = mkForce {
            wrappers = {
              atuin = global.config.anvil.programs.atuin.getPackage {inherit pkgs;};
              editor = global.config.anvil.programs.editor.getPackage {
                inherit pkgs;
                metadata.editor = shell.editor.name;
              };
              git = global.config.anvil.programs.git.getPackage {inherit pkgs config;};
            };
          };

          envVariables = {
            NH_FLAKE = host.metadata.nixPath;
          };

          shellAliases = let
            nixFlakePath = host.metadata.nixPath;
          in {
            ntest = "nh os test ${nixFlakePath} -H ${host.name}";
            nboot = "nh os boot ${nixFlakePath} -H ${host.name}";
            nswitch = "nh os switch ${nixFlakePath} -H ${host.name}";
            nbuild-vm = "nh os build-vm ${nixFlakePath} -H ${host.name}";
            nclean = "nh clean all --optimise -k ${toString host.metadata.configurationLimit}";
            nshell = "nix-shell --command ${program.metadata.shell.name} -p";
          };
        };
    programs = {program, ...}: [
      "git"
      program.metadata.shell.multiplexer.name
      program.metadata.shell.prompt.name
    ];
    nixos = commonModule;
    darwin = commonModule;
  };

  flake.wrappers.shell = {...}: {
    imports = [
      self.wrapperModules.${shell.name}
      (self.dotfiles.shell.getConfiguration {inherit defaultConfiguration;})
    ];
  };
}
