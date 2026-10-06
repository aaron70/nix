{...}: {
  anvil.features.gaming = {
    programs = [
      "steam"
    ];
    nixos = {pkgs, ...}: {
      boot.kernel.sysctl = {
        "kernel.split_lock_mitigate" = 0;
        "vm.swappiness" = 100;
        "vm.max_map_count" = 2147483642;
      };

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
