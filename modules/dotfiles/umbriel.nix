{lib, ...}:
with lib; {
  flake.dotfiles.umbriel.default = {config, ...}: {
    general = {
      autostart = [
        "xwayland-satellite"
        "${getExe config.desktopShell}"
      ];
      mod_key = "${config.modKey}";
      show_cheatsheet = false;
      focus_on_activate = true;
    };

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      SDL_VIDEODRIVER = "wayland";
    };

    output =
      mapAttrs (
        name: monitor: let
          mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";
        in {
          enabled = monitor.enabled;
          mode = mode;
          position = [monitor.x monitor.y];
          scale = monitor.scale;
          vrr = "always";
          hdr = "auto";
        }
      )
      config.monitors;

    input = {
      focus = {
        follows_mouse = true;
        follows_mouse_max_scroll = 0.5;
      };
      cursor = {
        follows_focus = true;
        hide_when_typing = true;
      };
    };

    layout = {
      gap = 5;
      extent_presets = [0.333 0.5 0.667 1];
      struts = {
        left = 13;
        right = 13;
      };

      scrolling = {
        center_focused = "never";
      };
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
        allow_when_locked = true;
        repeat = false;
      };
      "Mod+Return" = {
        action = "overview-toggle";
        repeat = false;
      };
      "Mod+Shift+Return" = {
        action = "cheatsheet-toggle";
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

      # Submaps

      "Mod+W" = {
        action = "submap:windows";
        repeat = false;
      };
      "submap[windows],c" = {
        action = "column-center";
        submap = "windows";
      };
      "submap[windows],Escape" = "submap:reset";

      # Special key bindings

      "Mod+V" = "spawn:noctalia msg panel-toggle clipboard";

      "Ctrl+Shift+3" = "spawn:screenshot-region";
      "Ctrl+Shift+4" = "spawn:screenshot-fullscreen pick";
      "Ctrl+Shift+5" = "spawn:screenshot-annotate";

      "XF86AudioRaiseVolume" = {
        action = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
        allow_when_locked = true;
      };
      "XF86AudioLowerVolume" = {
        action = "spawn:wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
        allow_when_locked = true;
      };
      "XF86AudioMute" = {
        action = "spawn:wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        allow_when_locked = true;
      };
      "XF86AudioMicMute" = {
        action = "spawn:wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        allow_when_locked = true;
      };

      "XF86AudioPlay" = {
        action = "spawn:playerctl play-pause";
        allow_when_locked = true;
      };
      "XF86AudioStop" = {
        action = "spawn:playerctl stop";
        allow_when_locked = true;
      };
      "XF86AudioNext" = {
        action = "spawn:playerctl next";
        allow_when_locked = true;
      };
      "XF86AudioPrev" = {
        action = "spawn:playerctl previous";
        allow_when_locked = true;
      };

      "XF86MonBrightnessUp" = {
        action = "spawn:brightnessctl set +5%";
        allow_when_locked = true;
      };
      "XF86MonBrightnessDown" = {
        action = "spawn:brightnessctl set 5%-";
        allow_when_locked = true;
      };

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
