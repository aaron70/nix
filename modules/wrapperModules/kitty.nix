{lib, ...}:
with lib; {
  flake.wrappers._kitty = {
    config,
    wlib,
    pkgs,
    ...
  }: {
    imports = [wlib.modules.default];

    options = {
      configuration = mkOption {
        type = types.str;
        description = "The Kitty configuration file's contents.";
        default = "";
      };
    };

    config = {
      package = pkgs.kitty;
      # flagSeparator="=";
      flags."--config" = pkgs.writeText "kitty.conf" config.configuration;
    };
  };
}
