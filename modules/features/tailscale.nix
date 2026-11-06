{lib, ...}:
with lib; {
  anvil.features.tailscale = {
    nixos = {
      host,
      user ? null,
      ...
    }: let
      mainUser = host.metadata.mainUser or null;
    in {
      assertions = [
        {
          assertion = user == null;
          message = "tailscale: Feature 'tailscale' must be listed under a host's `features`, not evaluated per user (user '${user.name or "?"}').";
        }
        {
          assertion = mainUser != null;
          message = "tailscale: Feature 'tailscale' requires host '${host.name or "?"}' to define `metadata.mainUser`.";
        }
      ];

      services.tailscale = {
        enable = true;
        # Opens the WireGuard UDP port (41641) on all interfaces.
        openFirewall = true;
        # Client only: no subnet routing, no exit node, no IP forwarding.
        useRoutingFeatures = "none";
        # Run `tailscale status/set/up` without sudo as the main user.
        extraSetFlags = ["--ssh"] ++ optional (mainUser != null) "--operator=${mainUser}";
      };

      # The tailnet interface is intentionally NOT trusted: every tailnet peer could
      # otherwise reach every local port. Open services explicitly, e.g.:
      #   networking.firewall.interfaces.tailscale0.allowedTCPPorts = [22];
    };
  };
}
