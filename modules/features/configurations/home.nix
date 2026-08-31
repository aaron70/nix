{
  inputs,
  self,
  lib,
  config,
  ...
}:
with lib; {
  anvil.features.homeManager = {
    darwin = {
      host,
      user,
      ...
    } @ ctx: let
      user =
        if ctx.user == null
        then config.anvil.users.${host.metadata.mainUser}
        else ctx.user;
    in {
      imports = [inputs.home-manager.darwinModules.home-manager];

      config = {
        home-manager.users.${user.name} = {...}: {
          imports = [inputs.mac-app-util.homeManagerModules.default] ++ self.lib.getHostModules "home" host;
          config = {
            programs.home-manager.enable = true;
            home = {
              username = user.name;
              homeDirectory = mkDefault user.homeDir.darwin;
              stateVersion = host.stateVersion;
            };
          };
        };
      };
    };

    nixos = {
      host,
      user,
      ...
    } @ ctx: let
      user =
        if ctx.user == null
        then config.anvil.users.${host.metadata.mainUser}
        else ctx.user;
    in {
      imports = [inputs.home-manager.nixosModules.default];

      config = {
        home-manager.users.${user.name} = {...}: {
          imports = self.lib.getHostModules "home" host;
          config = {
            programs.home-manager.enable = true;
            home = {
              username = user.name;
              homeDirectory = mkDefault user.homeDir.nixos;
              stateVersion = host.stateVersion;

              file.".XCompose".text = ''
                include "%L"

                # Acute accents (mimics macOS Option+e then vowel)
                <Multi_key> <e> <a> : "á"
                <Multi_key> <e> <e> : "é"
                <Multi_key> <e> <i> : "í"
                <Multi_key> <e> <o> : "ó"
                <Multi_key> <e> <u> : "ú"
                <Multi_key> <e> <A> : "Á"
                <Multi_key> <e> <E> : "É"
                <Multi_key> <e> <I> : "Í"
                <Multi_key> <e> <O> : "Ó"
                <Multi_key> <e> <U> : "Ú"

                # Tilde (mimics macOS Option+n then n)
                <Multi_key> <n> <n> : "ñ"
                <Multi_key> <n> <N> : "Ñ"

                # Diaeresis
                <Multi_key> <u> <u> : "ü"
                <Multi_key> <u> <U> : "Ü"

                # Inverted punctuation
                <Multi_key> <exclam> <exclam> : "¡"
                <Multi_key> <question> <question> : "¿"
              '';
            };
          };
        };
      };
    };
  };
}
