{inputs, ...}: {
  anvil.programs.zen = {
    getPackage = {pkgs, ...}: inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
