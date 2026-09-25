{inputs, ...}: {
  anvil.programs.zen = {
    getPackage = {pkgs, ...}: inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    home = {...}: {
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        policies = {
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
        };

        profiles.default.settings = {
          "zen.workspaces.continue-where-left-off" = true;
          "zen.view.compact.hide-tabbar" = true;
          "zen.urlbar.behavior" = "float";
          "zen.welcome-screen.seen" = true;
        };
      };
    };
  };
}
