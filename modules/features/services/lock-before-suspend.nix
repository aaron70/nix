{
  config,
  lib,
  ...
} @ global:
with lib; {
  anvil.features.lock-before-suspend = {
    nixos = {
      pkgs,
      user,
      ...
    }: let
      noctalia = global.config.anvil.programs.noctalia.getPackage {inherit pkgs;};
    in {
      assertions = [
        {
          assertion = user != null;
          message = "The lock-before-suspend requires a user, but user is null";
        }
      ];
      systemd.services.lock-before-suspend = {
        enable = true;
        description = "Locks the session before sleep";
        wantedBy = ["sleep.target"];
        before = ["sleep.target"];
        serviceConfig = {
          Type = "oneshot";
          User = user.name;
          ExecStart = pkgs.writeShellScript "lock-screen" ''
            set -e
            ${getExe noctalia} msg session lock

            for i in $(seq 1 20); do
              locked=$(${getExe noctalia} msg status | ${getExe pkgs.jq} .locked)
              if [ "$locked" = "true" ]; then
                exit 0
              fi
              sleep 0.1
            done

            echo "Timed out waiting for session lock" >&2
            exit 1
          '';
        };
        environment = {
          XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${user.name}.uid}";
          WAYLAND_DISPLAY = "wayland-1";
        };
      };
    };
  };
}
