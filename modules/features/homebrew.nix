{...}: {
  anvil.features.homebrew = {
    # NOTE: Consider whether to manage homebrew trough the `github:zhaofengli/nix-homebrew` flake for a truly declarative setup. Currently with the manual install is enough.
    darwin = {...}: {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = false;
          upgrade = false;
          cleanup = "uninstall";
        };
        taps = [];
        brews = [];
        casks = [];
        masApps = {};
      };
    };
  };
}
