{
  self,
  lib,
  ...
}:
with lib; let
  name = "niri";
in {
  flake.darwinModules.programs = self.lib.mkDarwinProgram name ({...}: {});

  flake.homeModules.programs = self.lib.mkHomeProgram name ({...}: {});

  flake.nixosModules.programs = self.lib.mkNixosProgram name ({...}: {});

  flake.programs.${name} = self.lib.mkProgram name ({...}: {
    configurations = [self.definitions.programs.desktop];
  });

  flake.wrappers.niri = {
    wlib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      (self.lib.mkConfigurationsOption [self.definitions.programs.desktop])
      wlib.wrapperModules.niri
    ];

    config = {
      passthru.providedSessions = ["niri"];
      runtimePkgs = with pkgs;
        [
          xwayland-satellite
          jq
        ]
        ++ config.configurations.packages;

      env.FONTCONFIG_FILE = "${config.configurations.fontsConfig}";

      "config.kdl".content = let
        terminal = getExe config.configurations.terminal;
        appLauncher = getExe config.configurations.appLauncher;
        browser = getExe config.configurations.browser;
        host = "aaronv";
        monitorConfigurations = concatStringsSep "\n\n" (mapAttrsToList
          (
            name: monitor: let
              mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";
            in ''
              output "${name}" {
                ${
                if monitor.enabled
                then ""
                else "off"
              }
                mode "${mode}"
                position x=${toString monitor.x} y=${toString monitor.y}
                scale ${toString monitor.scale}
                variable-refresh-rate on-demand=true
                ${
                if monitor.primary
                then "focus-at-startup"
                else ""
              }

                hot-corners {
                  bottom-right
                }
              }
            ''
          )
          config.configurations.monitors);
      in ''
        // ==================== | Launch apps | ====================
        spawn-at-startup "noctalia"
        // spawn-at-startup "polkit-gnome-authentication-agent-1" // NOTE: Using the built-in noctalia polkit-agent
        spawn-at-startup "xwayland-satellite"
        spawn-at-startup "${getExe config.configurations.desktopShell}"



        // ==================== | Miscellaneous | ====================
        screenshot-path "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"
        prefer-no-csd
        hotkey-overlay {
          skip-at-startup
        }

        environment {
          DISPLAY ":0"
          ELECTRON_OZONE_PLATFORM_HINT "auto"
        }

        debug {
          // Allows notification actions and window activation from Noctalia.
          honor-xdg-activation-with-invalid-serial
        }



        // ==================== | Input | ====================
        cursor {
          // xcursor-theme ""
          // xcursor-size

          hide-when-typing
          hide-after-inactive-ms 1000
        }

        input {
          mod-key "${config.configurations.modKey}"
          mod-key-nested "${config.configurations.modKeyAlt}"
          warp-mouse-to-focus
          focus-follows-mouse max-scroll-amount="5%"

          keyboard {
            xkb {
              layout "us"
              variant ""
              options "compose:ralt"
            }
            numlock
          }

          touchpad {
            tap
            natural-scroll
            accel-speed 0.2
            scroll-factor 0.9
          }

          mouse {
            accel-speed -0.7
          }
        }



        // ==================== | Layout | ====================
        layout {
          gaps 5
          center-focused-column "on-overflow"
          always-center-single-column
          default-column-width { proportion 0.5; }

          preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
          }

          preset-window-heights {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
          }

          focus-ring {
            off
            width 2
            active-color "#7fc8ff"
            inactive-color "#505050"
          }

          border {
            // off
            width 4
            active-color "#7aa2f7"
            inactive-color "#505050"
            urgent-color "#9b0000"
          }

          struts {
            left 13
            right 13
          }

          tab-indicator {
              gap 4
              length total-proportion=0.5
              position "left"
              place-within-column
              hide-when-single-tab
          }
        }



        // ==================== | Window Rules | ====================
        window-rule {
          open-maximized true
          geometry-corner-radius 3
          clip-to-geometry true

          draw-border-with-background false
          opacity 0.75
          variable-refresh-rate true

          background-effect {
            blur true
            xray true
          }
        }

        // Remove transparency from windows with videos
        window-rule {
          match title=r#"(?i)youtube"#
          opacity 1.0
          background-effect {
            blur false
            xray false
          }
        }

        // Block out password managers from screencasts.
        window-rule {
            match app-id=r#"^org\.keepassxc\.KeePassXC$"#
            match app-id=r#"^org\.gnome\.World\.Secrets$"#
            match title=r#"(?i)bit(-)?warden"#
        
            block-out-from "screencast"
        }

        // Indicate screencasted windows with red colors.
        window-rule {
            match is-window-cast-target=true
        
            focus-ring {
                active-color "#f38ba8"
                inactive-color "#7d0d2d"
            }
        
            border {
                inactive-color "#7d0d2d"
            }
        
            shadow {
                color "#7d0d2d70"
            }
        
            tab-indicator {
                active-color "#f38ba8"
                inactive-color "#7d0d2d"
            }
        }

        // Steam notifications
        window-rule {
            match app-id="steam" title=r#"^notificationtoasts_\d+_desktop$"#
            default-floating-position x=10 y=10 relative-to="bottom-right"
        }

        // Steam games on fullscreen
        window-rule {
            match app-id=r#"^steam_app_.*$"#

            open-fullscreen true
            open-on-workspace "gaming"
        }



        // ==================== | Layer Rules | ====================
        // Noctalia backgroun on overview mode
        layer-rule {
          match namespace="^noctalia-backdrop"
          place-within-backdrop true
        }

        layer-rule {
          match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"

          background-effect {
            xray false
            blur false
          }

          popups {
            opacity 1.0
            // geometry-corner-radius 15

            background-effect {
                xray false
                blur false
            }
          }
        }

        blur {
          passes 3        // more passes = stronger blur (default: 3)
          offset 3.0      // sample distance per pass (default: 3.0)
          noise 0.03      // grain overlay (default: 0.02)
          saturation 1.5  // color saturation boost (default: 1.5)
        }

        animations {
          // off
          workspace-switch {
            off
          }
        }



        // ==================== | Workspaces | ====================
        spawn-at-startup "${terminal}"
        workspace "terminal"
        window-rule {
            match at-startup=true app-id=r#"^${terminal}$"#
            open-on-workspace "terminal"
            open-maximized true
        }

        workspace "browser"
        window-rule {
            match at-startup=true app-id=r#"^${browser}$"#
            open-on-workspace "browser"
            open-maximized true
        }

        workspace "multimedia"
        window-rule {
            match at-startup=true app-id=r#"^spotify$"#
            open-on-workspace "multimedia"
            open-maximized true
        }

        workspace "gaming"
        window-rule {
            match at-startup=true app-id=r#"^steam$"#
            open-on-workspace "gaming"
            open-maximized true
        }

        workspace "chat"
        window-rule {
            match at-startup=true app-id=r#"^discord$"#
            open-on-workspace "chat"
            open-maximized true
        }

        workspace "temporal"


        // ==================== | Monitors | ====================
        ${monitorConfigurations}



        // ==================== | Bindings | ====================
        binds {
          // Powers off the monitors. To turn them back on, do any input like
          // moving the mouse or pressing any other key.
          Ctrl+Shift+P { power-off-monitors; }

          Mod+Shift+E { quit; }
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+Space repeat=false hotkey-overlay-title="Open a Terminal" { spawn "${terminal}"; }
          Mod+X repeat=false hotkey-overlay-title="Closes the focused window" { close-window; }
          Mod+D hotkey-overlay-title="Run the Application Launcher: ${appLauncher}" { spawn "${appLauncher}"; }
          Mod+V hotkey-overlay-title="Open the clipboard history app" { spawn "clipboard-history"; }


          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0"; } // "-l 1.0" limits the volume to 100%.
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"; }
          XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

          XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
          XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
          XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
          XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }

          XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+5%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "5%-"; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Shift+Left  { move-column-left; }
          Mod+Shift+Down  { move-window-down; }
          Mod+Shift+Up    { move-window-up; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+H     { move-column-left; }
          Mod+Shift+J     { move-window-down; }
          Mod+Shift+K     { move-window-up; }
          Mod+Shift+L     { move-column-right; }

          Mod+Ctrl+H { consume-or-expel-window-left; }
          Mod+Ctrl+L { consume-or-expel-window-right; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }

          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }

          Mod+Minus { set-window-width "-10%"; }
          Mod+Equal { set-window-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          Mod+U { focus-workspace "terminal"; }
          Mod+I { focus-workspace "browser"; }
          Mod+O { focus-workspace "chat"; }
          Mod+P { focus-workspace "multimedia"; }
          Mod+G { focus-workspace "gaming"; }
          Mod+T { focus-workspace "temporal"; }

          Mod+Shift+U { move-column-to-workspace "terminal"; }
          Mod+Shift+I { move-column-to-workspace "browser"; }
          Mod+Shift+O { move-column-to-workspace "chat"; }
          Mod+Shift+P { move-column-to-workspace "multimedia"; }
          Mod+Shift+G { move-column-to-workspace "gaming"; }
          Mod+Shift+T { move-column-to-workspace "temporal"; }

          Mod+Comma { move-workspace-to-monitor-previous; }
          Mod+Period { move-workspace-to-monitor-next; }

          Mod+Tab { toggle-column-tabbed-display; }

          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          // Mod+Ctrl+F { toggle-window-floating; }
          Mod+Ctrl+F {
              spawn-sh "if [ \"$(niri msg -j focused-window | jq -r .is_floating)\" = \"false\" ]; then niri msg action toggle-window-floating && niri msg action set-window-width -- 60% && niri msg action set-window-height -- 60%; else niri msg action toggle-window-floating; fi"
          }
          Mod+S { switch-preset-column-width; }
          Mod+C { center-visible-columns; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

          Ctrl+Shift+3 { screenshot-screen; }
          Ctrl+Shift+5 { screenshot-window; }
          Ctrl+Shift+4 { screenshot; }

          Mod+Ctrl+Shift+W { set-dynamic-cast-window; }
          Mod+Ctrl+Shift+M { set-dynamic-cast-monitor; }
          Mod+Ctrl+Shift+C { clear-dynamic-cast-target; }
        }
      '';
    };
  };
}
