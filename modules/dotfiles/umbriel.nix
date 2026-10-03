{lib, ...}:
with lib; {
  flake.dotfiles.umbriel.default = {config, ...}: {
    general = {
      autostart = [
        "xwayland-satellite"
        "${getExe config.desktopShell}"
      ];
      mod_key = "${config.modKey}";
    };

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      SDL_VIDEODRIVER = "wayland";
    };

    layout = {
      extent_presets = [ 0.333 0.5 0.67 1 ];
    };

    animation = {
      enabled = true;
      workspaces.enabled = false;
      windows_move = {
        enabled = true;
        curve = "spring:1,800";
      };
    };

    appearance = {
      blur = {
        enabled = true;
        optimized = true;
        passes = 3;
        radius = 5;
        noise = 0.02;
        brightness = 0.9;
        contrast = 0.9;
        saturation = 1.1;
      };
    };

    window_rule = [
      {
        match.is_focused = true;
        blur = true;
        opacity = 0.85;
        corner_radius = 10;
      }
      {
        match.is_focused = false;
        blur = true;
        opacity = 0.75;
        corner_radius = 10;
      }
      {
        match.title = "[Yy][Oo][Uu][Tt][Uu][Bb][Ee]";
        # match.content_type = "video";
        opacity = 1.0;
        blur = false;
      }
      {
        match.content_type = "video";
        opacity = 1.0;
        blur = false;
      }
      {
        match.content_type = "photo";
        opacity = 1.0;
        blur = false;
      }
      {
        match.title = "^steam_app_[0-9]+$";
        match.content_type = "game";
        default_workspace = "gaming";
        # default_fullscreen = true;
      }
    ];

    workspace = [
      {name = "kyoten";}
      {name = "browser";}
      {name = "comunication";}
      {name = "media";}
      {name = "gaming";}
      {name = "temporal";}
    ];

    keybinds = {
      # Applications and session
      "Mod+Space" = {
        action = "spawn:${getExe config.terminal}";
        repeat = false;
      };
      "Mod+X" = "window-close";
      "Mod+D" = "spawn:${getExe config.appLauncher}";
      "Mod+Escape" = "session-quit";
      "Mod+Shift+Escape" = {
        action = "shortcuts-inhibit-toggle";
        allow_when_inhibited = true;
        repeat = false;
      };
      "Mod" = {
        action = "overview-toggle";
        repeat = false;
      };

      # Focus and movement
      "Mod+Left" = "window-focus-left";
      "Mod+Down" = "window-focus-down";
      "Mod+Up" = "window-focus-up";
      "Mod+Right" = "window-focus-right";
      "Mod+H" = "window-focus-left";
      "Mod+J" = "window-focus-down";
      "Mod+K" = "window-focus-up";
      "Mod+L" = "window-focus-right";
      "Mod+F1" = "window-focus-next";
      "Mod+Shift+Left" = "column-move-left";
      "Mod+Shift+Down" = "window-move-down";
      "Mod+Shift+Up" = "window-move-up";
      "Mod+Shift+Right" = "column-move-right";
      "Mod+Shift+H" = "column-move-left";
      "Mod+Shift+J" = "window-move-down";
      "Mod+Shift+K" = "window-move-up";
      "Mod+Shift+L" = "column-move-right";

      "Mod+Comma" = "window-move-to-output-next";
      "Mod+Period" = "window-move-to-output-previous";

      # Window state and layout
      "Mod+F" = {
        action = "window-toggle-floating";
        repeat = false;
      };
      "Mod+Ctrl+Shift+F" = {
        action = "window-focus-switch-floating";
        repeat = false;
      };
      "Mod+Shift+F" = {
        action = "window-toggle-fullscreen";
        repeat = false;
      };
      "Mod+Ctrl+F" = {
        action = "window-toggle-maximize";
        repeat = false;
      };
      "Mod+M" = {
        action = "window-toggle-maximize-to-edges";
        repeat = false;
      };
      "Mod+S" = "window-cycle-primary-extent";
      "Mod+Shift+S" = "window-cycle-primary-extent-back";
      "Mod+Ctrl+P" = {
        action = "window-toggle-pinned";
        repeat = false;
      };

      # Workspaces
      "Mod+1" = "workspace-switch:1";
      "Mod+2" = "workspace-switch:2";
      "Mod+3" = "workspace-switch:3";
      "Mod+4" = "workspace-switch:4";
      "Mod+5" = "workspace-switch:5";
      "Mod+6" = "workspace-switch:6";
      "Mod+7" = "workspace-switch:7";
      "Mod+8" = "workspace-switch:8";
      "Mod+9" = "workspace-switch:9";
      "Mod+Shift+1" = "window-move-to-workspace:1";
      "Mod+Shift+2" = "window-move-to-workspace:2";
      "Mod+Shift+3" = "window-move-to-workspace:3";
      "Mod+Shift+4" = "window-move-to-workspace:4";
      "Mod+Shift+5" = "window-move-to-workspace:5";
      "Mod+Shift+6" = "window-move-to-workspace:6";
      "Mod+Shift+7" = "window-move-to-workspace:7";
      "Mod+Shift+8" = "window-move-to-workspace:8";
      "Mod+Shift+9" = "window-move-to-workspace:9";

      "Mod+U" = "workspace-switch:kyoten";
      "Mod+I" = "workspace-switch:browser";
      "Mod+O" = "workspace-switch:comunication";
      "Mod+P" = "workspace-switch:media";
      "Mod+G" = "workspace-switch:gaming";
      "Mod+T" = "workspace-switch:temporal";
      "Mod+Shift+U" = "window-move-to-workspace:kyoten";
      "Mod+Shift+I" = "window-move-to-workspace:browser";
      "Mod+Shift+O" = "window-move-to-workspace:comunication";
      "Mod+Shift+P" = "window-move-to-workspace:media";
      "Mod+Shift+G" = "window-move-to-workspace:gaming";
      "Mod+Shift+T" = "window-move-to-workspace:temporal";

      # "Mod+W" = { action = "column-toggle-tabbed"; repeat = false; };
      # "Mod+Alt+Right" = "column-focus-tab-next";
      # "Mod+Alt+Left" = "column-focus-tab-previous";
      # "Mod+WheelUp" = "window-focus-left";
      # "Mod+WheelDown" = "window-focus-right";
    };

    # layout.gap = 5;
    # input.keyboard.layout = "de";
  };

  flake.dotfiles.umbriel.toml = {config, ...}: ''
    [general]
    autostart = [ "${getExe config.desktopShell}" ]
    mod_key = "${config.modKey}"

    [environment]
    ELECTRON_OZONE_PLATFORM_HINT = "auto"
    SDL_VIDEODRIVER = "wayland"

    [keybinds]
    "Mod+T" = "spawn:${getExe config.terminal}"
    "Mod+K" = "window-close"
    "Mod+I" = "overview-toggle"
    "Mod+L" = "window-focus-left"
    "Mod+H" = "window-focus-right"

  '';
}
