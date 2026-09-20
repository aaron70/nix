{self, ...}: {
  flake.dotfiles.oh-my-posh.tty = {colors, ...}:
    self.dotfiles.oh-my-posh.theme {
      inherit colors;
      pathStyle = "full";
      promptGlyph = "> ";
      powerline = false;
      upstreamIcon = false;
      osIcon = false;
    };
}
