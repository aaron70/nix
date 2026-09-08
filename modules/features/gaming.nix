{...}: {
  anvil.features.gaming = {
    programs = [
      "steam"
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # Communication
        discord

        # Games
        ryubing # Nintendo Switch simulator
        pokemmo-installer # PokeMMO
        (heroic.override {extraPkgs = pkgs: [pkgs.gamescope];}) # Epic Games Launcher

        # Tools/Dependencies/Compatibility
        mangohud
        protonup-ng
      ];
    };
  };
}
