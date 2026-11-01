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
        # ryubing # Nintendo Switch simulator # NOTE: I've disabled it because I'm not currently playing nothing from Nintentod
        # pokemmo # PokeMMO # FIX: This is failing because of a hash (probably caused by the package maintainer)
        # (heroic.override {extraPkgs = pkgs: [pkgs.gamescope];}) # Epic Games Launcher # NOTE: I've disabled it because I'm not currently playing nothing from Nintentod

        # Tools/Dependencies/Compatibility
        mangohud
        protonup-ng
      ];
    };
  };
}
