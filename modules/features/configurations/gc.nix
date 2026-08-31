{lib, ...}:
with lib; {
  anvil.features.gc = {
    nixos = {
      host,
      user,
      config,
      pkgs,
      ...
    }: {
      config = let
        notify = user: msg:
          "${pkgs.sudo}/bin/sudo -u ${user} "
          + "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(${pkgs.coreutils}/bin/id -u ${user})/bus "
          + "${pkgs.libnotify}/bin/notify-send ${lib.escapeShellArg msg}";
        username = if user == null then host.metadata.mainUser else user.name;
      in {
        systemd.services.gc-periodic = {
          enable = true;
          description = "Periodic nix store cleanup";
          path = [config.nix.package];
          serviceConfig = {
            Type = "oneshot";
            ExecStartPre = pkgs.writeShellScript "notify-start" ''
              ${notify username "Starting nix store cleanup..."}
            '';
            ExecStart = pkgs.writeShellScript "gc-clean" ''
              set -e
              ${getExe pkgs.nh} clean all --optimise -k ${toString host.metadata.configurationLimit}
            '';
            ExecStartPost = pkgs.writeShellScript "notify-done" ''
              ${notify username "Nix store cleanup complete"}
            '';
            TimeoutStopSec = "5min";
          };
        };

        systemd.timers.gc-periodic = {
          enable = true;
          description = "Timer for periodic nix store cleanup via nh";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
            RandomizedDelaySec = "30min";
          };
        };
      };
    };

    darwin = {
      config,
      pkgs,
      ...
    }: {
      config = {
        launchd.daemons.gc-periodic = {
          serviceConfig = {
            ProgramArguments = [
              "${pkgs.writeShellScript "gc-clean-darwin" ''
                set -e
                export PATH="${config.nix.package}/bin:${pkgs.nh}/bin:$PATH"
                ${getExe pkgs.nh} clean all --optimise -k ${toString host.metadata.configurationLimit}
              ''}"
            ];
            StartCalendarInterval = [
              {
                Weekday = 1;
                Hour = 7;
                Minute = 30;
              } # Monday 7:30am
            ];
            StandardOutPath = "/var/log/gc-periodic.log";
            StandardErrorPath = "/var/log/gc-periodic.log";
          };
        };
      };
    };
  };
}
