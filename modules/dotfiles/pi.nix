{...}: {
  flake.dotfiles.pi.default = {...}: {
    defaultProvider = "opencode-go";
    defaultModel = "claude-haiku-5-5";
  };
}
