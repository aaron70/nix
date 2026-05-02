{lib, ...}:
with lib; {
  flake.wrappers._ghostty = {
    config,
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    options = {
      configuration = mkOption {
        type = types.str;
        description = "The Ghostty configuration file's contents.";
        default = "";
      };
    };

    config = {
      package =
        if pkgs.stdenv.isDarwin
        then pkgs.ghostty-bin
        else pkgs.ghostty;
      flagSeparator = "=";
      flags."--config-file" = pkgs.writeText "config.ghostty" config.configuration;
    };
  };
}
