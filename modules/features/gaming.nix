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
        vesktop

        # Games
        ryubing # Nintendo Switch simulator
        (heroic.override {extraPkgs = pkgs: [pkgs.gamescope];}) # Epic Games Launcher
        # pokemmo # PokeMMO # FIX: This is failing because of a hash (probably caused by the package maintainer) 

        # Tools/Dependencies/Compatibility
        mangohud
        protonup-ng
      ];
    };
  };
}
