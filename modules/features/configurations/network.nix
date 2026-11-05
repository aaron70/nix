{lib, ...}:
with lib; let
  mkProfile = ssid: psk: {
    connection = {
      id = ssid;
      type = "wifi";
    };
    wifi = {
      ssid = ssid;
      mode = "infrastructure";
    };
    wifi-security = {
      key-mgmt = "wpa-psk";
      psk = psk;
    };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };
in {
  anvil.features.network = {
    features = [
      "global-secrets"
    ];
    nixos = {
      user,
      host,
      pkgs,
      config,
      ...
    }: let
      mainUser = host.metadata.mainUser or null;
    in {
      assertions = [
        {
          assertion = user == null;
          message = "network: Configuration feature 'network' must be listed under a host's `features`, not evaluated per user (user '${user.name or "?"}').";
        }
        {
          assertion = mainUser != null;
          message = "network: Configuration feature 'network' requires host '${host.name or "?"}' to define `metadata.mainUser`.";
        }
      ];

      sops.templates."wifi.env".content = ''
        HOME_SSID=${config.sops.placeholder."wifi/home/ssid"}
        HOME_SSID_5G=${config.sops.placeholder."wifi/home/ssid_5g"}
        HOME_PSK=${config.sops.placeholder."wifi/home/psk"}
        HOTSPOT_SSID=${config.sops.placeholder."wifi/hotspot/ssid"}
        HOTSPOT_PSK=${config.sops.placeholder."wifi/hotspot/psk"}
      '';
      networking.firewall.enable = true;
      networking.nftables.enable = true;
      networking.hostName = mkIf pkgs.stdenv.hostPlatform.isLinux "${host.metadata.mainUser}-${host.name}";
      networking.networkmanager.enable = true;
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [config.sops.templates."wifi.env".path];
        profiles = {
          home = mkProfile "$HOME_SSID" "$HOME_PSK";
          home_5g = mkProfile "$HOME_SSID_5G" "$HOME_PSK";
          personal_hotspot = mkProfile "$HOTSPOT_SSID" "$HOTSPOT_PSK";
        };
      };
    };
  };
}
