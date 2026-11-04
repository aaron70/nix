{lib, ...}:
with lib; {
  anvil.features.tailscale = {
    nixos = {
      user,
      config,
      ...
    }: {
      services.tailscale = {
        enable = true;
        # Opens only the WireGuard UDP port (41641) on the physical interfaces.
        openFirewall = true;
        # Client only: no subnet routing, no exit node, no IP forwarding.
        useRoutingFeatures = "none";
        # Run `tailscale up/set/status` without sudo as this user (single-user machines only).
        extraUpFlags = mkIf (user != null) ["--operator=${user.name}"];
      };

      # Traffic arriving over the tailnet is already authenticated by WireGuard,
      # so the tailnet interface is trusted. Services stay closed on LAN/Wi-Fi.
      networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
    };
  };
}
