{self, ...}: {
  flake.wrapperHelpers.noctalia = {
    config.default = {...}: 
    let 
      wallpapersPath = "${self.lib.resourcesPath}/wallpapers";
      imagessPath = "${self.lib.resourcesPath}/images";
    in
    ''
[audio]
enable_sounds = true

[backdrop]
blur_intensity = 0.4999999888241291
enabled = true
tint_intensity = 0.0

[bar]
order = [ "default" ]

    [bar.default]
    background_opacity = 0.0
    capsule = true
    capsule_opacity = 0.75
    capsule_padding = 10.0
    capsule_radius = "auto"
    capsule_thickness = 0.89999998360872269
    center = [ "privacy", "media", "recorder_2" ]
    end = [ "group:g3", "group:g2", "group:g1", "group:g4" ]
    margin_edge = 5
    margin_ends = 10
    shadow = false
    start = [ "control-center", "workspaces" ]
    thickness = 25

        [[bar.default.capsule_group]]
        fill = "surface_variant"
        id = "g3"
        members = [ "network", "bluetooth" ]
        opacity = 0.75
        padding = 10.0

        [[bar.default.capsule_group]]
        fill = "surface_variant"
        id = "g2"
        members = [ "volume", "brightness", "battery" ]
        opacity = 0.75
        padding = 10.0

        [[bar.default.capsule_group]]
        fill = "surface_variant"
        id = "g4"
        members = [ "notifications", "session" ]
        opacity = 0.75
        padding = 10.0

        [[bar.default.capsule_group]]
        fill = "surface_variant"
        id = "g1"
        members = [ "clock", "date" ]
        opacity = 0.75
        padding = 10.0

[battery]
warning_threshold = 15

    [battery.device."/org/freedesktop/UPower/devices/headset_dev_80_99_E7_F0_E1_15"]
    warning_threshold = 30

[brightness]
enable_ddcutil = true
sync_all_monitors = true

[calendar]
enabled = true

    [calendar.account.personal_google]
    color = "primary"
    name = "Personal Calendar"
    type = "google"

[control_center]
hidden_tabs = []

    [[control_center.shortcuts]]
    type = "caffeine"

    [[control_center.shortcuts]]
    type = "nightlight"

    [[control_center.shortcuts]]
    type = "notification"

    [[control_center.shortcuts]]
    type = "power_profile"

    [[control_center.shortcuts]]
    type = "clipboard"

    [[control_center.shortcuts]]
    type = "noctalia/screen_recorder:toggle"

[dock]
active_monitor_only = true
active_scale = 1.1000000163912773
auto_hide = true
background_opacity = 0.99999997764825821
enabled = false
icon_size = 30
launcher_icon = "layout-dashboard-filled"
launcher_position = "start"
magnification_scale = 1.3000000044703484
main_axis_padding = 10
reserve_space = false
shadow = false

[idle]
behavior_order = [ "lock", "screen-off", "lock-and-suspend" ]
pre_action_fade_seconds = 10

    [idle.behavior.lock]
    action = "lock"
    enabled = true
    timeout = 610.0

    [idle.behavior.lock-and-suspend]
    action = "lock_and_suspend"
    enabled = true
    timeout = 900.0

    [idle.behavior.screen-off]
    action = "screen_off"
    enabled = true
    timeout = 600.0

[location]
auto_locate = true

[lockscreen]
blur_intensity = 0.64999998547136784
blurred_desktop = true
tint_intensity = 0.19999999552965164

[lockscreen_widgets]
enabled = true
schema_version = 2
widget_order = [
    "lockscreen-login-box@eDP-1",
    "lockscreen-login-box@HDMI-A-2",
    "lockscreen-login-box@DP-3",
    "lockscreen-login-box@HDMI-A-1",
    "lockscreen-login-box@DP-1",
    "lockscreen-login-box@winit",
    "lockscreen-login-box@eDP-1",
    "lockscreen-widget-0000000000000006",
    "lockscreen-widget-0000000000000003",
    "lockscreen-widget-0000000000000007",
    "lockscreen-widget-0000000000000008"
]

    [lockscreen_widgets.grid]
    cell_size = 16
    major_interval = 4
    visible = true

    [lockscreen_widgets.widget."lockscreen-login-box@DP-1"]
    box_height = 70.0
    box_width = 400.0
    cx = 960.0
    cy = 961.0
    output = "DP-1"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@DP-1".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget."lockscreen-login-box@DP-2"]
    box_height = 70.0
    box_width = 400.0
    cx = 1280.0
    cy = 1321.0
    output = "DP-2"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@DP-2".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget."lockscreen-login-box@DP-3"]
    box_height = 70.0
    box_width = 400.0
    cx = 960.0
    cy = 961.0
    output = "DP-3"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@DP-3".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-1"]
    box_height = 70.0
    box_width = 400.0
    cx = 1280.0
    cy = 1321.0
    output = "HDMI-A-1"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-1".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-2"]
    box_height = 70.0
    box_width = 400.0
    cx = 1280.0
    cy = 1321.0
    output = "HDMI-A-2"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-2".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget."lockscreen-login-box@eDP-1"]
    box_height = 70.0
    box_width = 400.0
    cx = 960.0
    cy = 961.0
    output = "eDP-1"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@eDP-1".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget."lockscreen-login-box@winit"]
    box_height = 70.0
    box_width = 400.0
    cx = 466.0
    cy = 913.0
    output = "winit"
    rotation = 0.0
    type = "login_box"

        [lockscreen_widgets.widget."lockscreen-login-box@winit".settings]
        background_color = "surface_variant"
        background_opacity = 0.88
        background_radius = 12.0
        input_opacity = 1.0
        input_radius = 6.0
        show_caps_lock = true
        show_keyboard_layout = true
        show_login_button = true
        show_password_hint = true

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000001]
    box_height = 0.0
    box_width = 0.0
    cx = 960.0
    cy = 156.0
    output = "DP-3"
    rotation = 0.0
    type = "clock"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000001.settings]
        background = false
        center_text = true
        shadow = false

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000002]
    box_height = 0.0
    box_width = 0.0
    cx = 960.0
    cy = 802.0
    output = "DP-3"
    rotation = 0.0
    type = "media_player"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000002.settings]
        background = false
        hide_when_no_media = true
        shadow = false

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000003]
    box_height = 128.0
    box_width = 416.0
    cx = 960.0
    cy = 796.0
    output = "eDP-1"
    rotation = 0.0
    type = "media_player"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000003.settings]
        background = false
        background_opacity = 0.78000000000000003
        color = "on_surface"
        hide_when_no_media = true
        layout = "horizontal"
        shadow = false

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000004]
    box_height = 0.0
    box_width = 0.0
    cx = 640.0
    cy = 538.0
    output = "eDP-1"
    rotation = 0.0
    type = "media_player"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000004.settings]
        background = false
        hide_when_no_media = true
        shadow = false

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000006]
    box_height = 0.0
    box_width = 0.0
    cx = 960.0
    cy = 188.0
    output = "eDP-1"
    rotation = 0.0
    type = "clock"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000006.settings]
        background = false
        center_text = true
        clock_style = "digital"
        shadow = false

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000007]
    box_height = 0.0
    box_width = 0.0
    cx = 960.0
    cy = 172.5
    output = "DP-1"
    rotation = 0.0
    type = "clock"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000007.settings]
        background = false
        shadow = false

    [lockscreen_widgets.widget.lockscreen-widget-0000000000000008]
    box_height = 0.0
    box_width = 0.0
    cx = 960.0
    cy = 812.0
    output = "DP-1"
    rotation = 0.0
    type = "media_player"

        [lockscreen_widgets.widget.lockscreen-widget-0000000000000008.settings]
        background = false
        hide_when_no_media = true
        shadow = false

[nightlight]
enabled = true
temperature_night = 3800

[osd]
background_opacity = 0.74999998323619366
position = "top_right"
position_vertical = "top_right"

[plugin_settings."noctalia/screen_recorder"]
color_range = "full"
hide_inactive = true
quality = "ultra"
replay_enabled = true
resolution = "original"

[plugin_settings."yocraft/web-launcher"]
icon_provider = "direct"
links = [
    "GitHub|https://github.com",
    "GitLab|https://gitlab.com",
    "Codeberg|https://codeberg.org",
    "Reddit|https://reddit.com",
    "YouTube|https://youtube.com",
    "Gmail|https://mail.google.com",
    "Whatsapp|https://web.whatsapp.com",
    "Teams|https://teams.live.com/v2"
]
notify = false

[plugins]
enabled = [ "noctalia/screen_recorder", "yocraft/web-launcher", "apex077/eyecare" ]

[shell]
avatar_path = "${imagessPath}/avatar.jpg"
font_family = "JetBrainsMono Nerd Font Mono"
launch_apps_as_systemd_services = true
niri_overview_type_to_launch_enabled = true
polkit_agent = true
screen_time_enabled = true
settings_show_advanced = true
show_location = false
telemetry_enabled = true

    [shell.launcher]
    app_grid = true
    compact = true
    session_search = true

        [shell.launcher.dmenu.entry.nixpkgs]
        command = "echo Nixpkgs"
        exec = "nixpkgs-search"
        global = false
        glyph = "package"
        prefix = "nix"

    [shell.panel]
    control_center_placement = "floating"
    list_item_background = true
    open_near_click_control_center = true
    open_near_click_session = true
    session_placement = "floating"
    session_position = "auto"
    wallpaper_placement = "floating"

    [shell.screen_corners]
    enabled = true
    size = 25

    [[shell.session.actions]]
    action = "lock"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "1"
    variant = "default"

    [[shell.session.actions]]
    action = "logout"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "2"
    variant = "default"

    [[shell.session.actions]]
    action = "lock_and_suspend"
    countdown_seconds = 0.0
    enabled = true
    glyph = "zzz"
    label = "Suspend"
    shortcut = "3"
    variant = "default"

    [[shell.session.actions]]
    action = "reboot"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "4"
    variant = "default"

    [[shell.session.actions]]
    action = "shutdown"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "5"
    variant = "destructive"

[theme]
builtin = "Tokyo-Night"
community_palette = "Tokyo Night Storm"
mode = "dark"
pure_black_dark = true
source = "builtin"
wallpaper_scheme = "m3-tonal-spot"

    [theme.templates]
    builtin_ids = [ "btop" ]
    community_ids = [ "zen-browser" ]

[wallpaper]
directory = "${wallpapersPath}"
transition_on_startup = true

    [wallpaper.automation]
    enabled = true
    interval_seconds = 900

    [wallpaper.default]
    path = "${wallpapersPath}/wallhaven.jpg"

    [wallpaper.last]
    path = "${wallpapersPath}/wallhaven.jpg"

    [wallpaper.monitors.DP-1]
    path = "${wallpapersPath}/wallhaven.jpg"

    [wallpaper.monitors.HDMI-A-1]
    path = "${wallpapersPath}/wallhaven.jpg"

    [wallpaper.monitors.HDMI-A-2]
    path = "${wallpapersPath}/wallhaven.jpg"

    [wallpaper.monitors.eDP-1]
    path = "${wallpapersPath}/wallhaven.jpg"

[widget.control-center]
anchor = true
capsule = true
glyph = "brand-dribbble-filled"

[widget.media]
hide_when_no_media = true
title_scroll = "always"

[widget.network]
show_label = false

[widget.privacy]
active_color = "error"
hide_inactive = true

[widget.recorder]
type = "noctalia/screen_recorder:recorder"

[widget.recorder_2]
type = "noctalia/screen_recorder:recorder"

[widget.workspaces]
anchor = true
display = "none"
hide_when_empty = true
pill_scale = 0.75
    '';
  };
}
