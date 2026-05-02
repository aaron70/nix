{lib, ...}:
with lib; {
  flake.wrappers._oh-my-posh = {
    config,
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    options = {
      configuration = mkOption {
        type = types.str;
        description = "The JSON configuration file's contents.";
        default = "";
      };
    };

    config = {
      package = pkgs.oh-my-posh;
      flags."--config" = pkgs.writeText "config.json" config.configuration;
    };
  };
}
