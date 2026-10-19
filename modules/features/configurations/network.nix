{
  self,
  lib,
  ...
}:
with lib; let
  commonModule = {
    pkgs,
    host,
    config,
    ...
  }: {
  };
in {
  anvil.features.network = {
    features = [
      "global-secrets"
    ];
    nixos = {
      pkgs,
      host,
      config,
      ...
    }: let
      ctx = {inherit host;};
    in {
      imports = [
        (self.lib.withContext ctx commonModule)
      ];
      networking.networkmanager.enable = true;
      networking.hostName = mkIf pkgs.stdenv.hostPlatform.isLinux "${host.metadata.mainUser}-${host.name}";
      sops.templates."wifi.env".content = ''
        HOME_SSID=${config.sops.placeholder."wifi/home/ssid"}
        HOME_SSID_5G=${config.sops.placeholder."wifi/home/ssid_5g"}
        HOME_PSK=${config.sops.placeholder."wifi/home/psk"}
      '';
      networking.networkmanager.ensureProfiles = {
        environmentFiles = [config.sops.templates."wifi.env".path];
        profiles = {
          home = {
            connection = {
              id = "$HOME_SSID";
              type = "wifi";
            };
            wifi = {
              ssid = "$HOME_SSID";
              mode = "infrastructure";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
          home_5g = {
            connection = {
              id = "$HOME_SSID_5G";
              type = "wifi";
            };
            wifi = {
              ssid = "$HOME_SSID_5G";
              mode = "infrastructure";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
        };
      };
    };
    darwin = commonModule;
  };
}
