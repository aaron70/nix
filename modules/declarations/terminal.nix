{lib, ...}:
with lib; {
  flake.declarations.terminal = {...}: {
    options = {
      terminalPackage = mkOption {
        type = types.package;
        description = "The package of the default terminal.";
      };
    };
  };
}
