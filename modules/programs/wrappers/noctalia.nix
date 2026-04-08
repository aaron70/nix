{ self, ... }: 

let 
  name = "noctalia";
in
{ 
  flake.nixosModules.programs = self.lib.mkNixosProgram name ({ ... }: {});
  flake.programs.${name} = self.lib.mkProgram name ({ ... }: {});

  flake.wrappers.${name} = { wlib, pkgs, ... }:
  {
    imports = [ wlib.wrapperModules.noctalia-shell ];
    
    config = let
      noctalia-plugins = pkgs.fetchgit {
        url = "https://github.com/noctalia-dev/noctalia-plugins";
        rev = "3e679731daadccf94edddbaadb0ce3204fb72454";
        sha256 = "sha256-AtZEYKVg5oudC+PzGssSbPIFY1p8R0DIybo7lrqyUiM=";
        sparseCheckout = [
          "privacy-indicator"
          "screen-recorder"
          "screen-toolkit"
        ];
      };
    in {
      extraPackages = with pkgs; [ 
        # Dependencies for Screen Recorder plugin: https://noctalia.dev/plugins/screen-recorder/
        gpu-screen-recorder

        # Dependencies for Screen Toolkit plugin: https://noctalia.dev/plugins/screen-toolkit/
        grim 
        slurp
        wl-clipboard
        (tesseract.override { enableLanguages = [ "eng" "spa" ]; })
        imagemagick
        zbar
        curl
        translate-shell
        wf-recorder
        ffmpeg
        gifski
      ];
      colors = {
        mError = "#f7768e";
        mHover = "#9ece6a";
        mOnError = "#16161e";
        mOnHover = "#16161e";
        mOnPrimary = "#16161e";
        mOnSecondary = "#16161e";
        mOnSurface = "#c0caf5";
        mOnSurfaceVariant = "#9aa5ce";
        mOnTertiary = "#16161e";
        mOutline = "#565f89";
        mPrimary = "#7aa2f7";
        mSecondary = "#bb9af7";
        mShadow = "#15161e";
        mSurface = "#1a1b26";
        mSurfaceVariant = "#24283b";
        mTertiary = "#9ece6a";
      };
      preInstalledPlugins = {
        privacy-indicator = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          src = "${noctalia-plugins}/privacy-indicator";
        };
        screen-recorder = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          src = "${noctalia-plugins}/screen-recorder";
        };
        screen-toolkit = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          src = "${noctalia-plugins}/screen-toolkit";
        };
      };
      pluginSettings = {
        privacy-indicator = {
          hideInactive = true;
          enableToast = true;
          removeMargins = false;
          iconSpacing = 4;
          activeColor = "error";
          inactiveColor = "none";
          micFilterRegex = "";
        };
        screen-recorder = {
          hideInactive = true;
          iconColor = "error";
          directory = "";
          filenamePattern = "recording_yyyyMMdd_HHmmss";
          frameRate = "60";
          audioCodec = "opus";
          videoCodec = "h264";
          quality = "very_high";
          colorRange = "limited";
          showCursor = true;
          copyToClipboard = false;
          audioSource = "default_output";
          videoSource = "portal";
          resolution = "original";
          replayEnabled = false;
          replayDuration = "30";
          customReplayDuration = "30";
          replayStorage = "ram";
          restorePortalSession = false;
          customFrameRate = "60";
        };
        screen-toolkit = {
          colorHistory = [ ];
          paletteColors = [ ];
          installedLangs = [
            "eng"
            "spa"
          ];
          transAvailable = false;
          selectedOcrLang = "eng";
          stateIsRunning = false;
          stateActiveTool = "";
          stateMirrorVisible = false;
          resultHex = "";
          resultRgb = "";
          resultHsv = "";
          resultHsl = "";
          colorCapturePath = "";
        };
      };
      settings = {
        appLauncher = {
          autoPasteClipboard = false;
          clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
          clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
          clipboardWrapText = true;
          customLaunchPrefix = "";
          customLaunchPrefixEnabled = false;
          density = "compact";
          enableClipPreview = true;
          enableClipboardHistory = true;
          enableSessionSearch = true;
          enableSettingsSearch = true;
          enableWindowsSearch = true;
          iconMode = "tabler";
          ignoreMouseInput = false;
          overviewLayer = true;
          pinnedApps = [ ];
          position = "top_center";
          screenshotAnnotationTool = "";
          showCategories = true;
          showIconBackground = false;
          sortByMostUsed = true;
          terminalCommand = "kitty -e";
          useApp2Unit = false;
          viewMode = "list";
        };
        audio = {
          mprisBlacklist = [ ];
          preferredPlayer = "spotify";
          spectrumFrameRate = 30;
          visualizerType = "linear";
          volumeFeedback = false;
          volumeFeedbackSoundFile = "";
          volumeOverdrive = false;
          volumeStep = 5;
        };
        bar = {
          autoHideDelay = 500;
          autoShowDelay = 150;
          backgroundOpacity = 0;
          barType = "floating";
          capsuleColorKey = "none";
          capsuleOpacity = 1;
          contentPadding = 2;
          density = "compact";
          displayMode = "always_visible";
          enableExclusionZoneInset = true;
          floating = false;
          fontScale = 1;
          frameRadius = 12;
          frameThickness = 8;
          hideOnOverview = false;
          marginHorizontal = 5;
          marginVertical = 5;
          middleClickAction = "none";
          middleClickCommand = "";
          middleClickFollowMouse = false;
          monitors = [ ];
          mouseWheelAction = "none";
          mouseWheelWrap = true;
          outerCorners = true;
          position = "top";
          reverseScroll = false;
          rightClickAction = "controlCenter";
          rightClickCommand = "";
          rightClickFollowMouse = true;
          screenOverrides = [ ];
          showCapsule = false;
          showOnWorkspaceSwitch = true;
          showOutline = false;
          useSeparateOpacity = true;
          widgetSpacing = 6;
          widgets = {
            center = [
              {
                defaultSettings = {
                  activeColor = "primary";
                  enableToast = true;
                  hideInactive = true;
                  iconSpacing = 4;
                  inactiveColor = "none";
                  micFilterRegex = "";
                  removeMargins = false;
                };
                id = "plugin:privacy-indicator";
              }
              {
                compactMode = false;
                hideMode = "hidden";
                hideWhenIdle = false;
                id = "MediaMini";
                maxWidth = 145;
                panelShowAlbumArt = true;
                scrollingMode = "hover";
                showAlbumArt = false;
                showArtistFirst = true;
                showProgressRing = true;
                showVisualizer = false;
                textColor = "none";
                useFixedWidth = false;
                visualizerType = "linear";
              }
            ];
            left = [
              {
                colorizeDistroLogo = false;
                colorizeSystemIcon = "none";
                customIconPath = "";
                enableColorization = false;
                icon = "noctalia";
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                characterCount = 2;
                colorizeIcons = false;
                emptyColor = "secondary";
                enableScrollWheel = true;
                focusedColor = "primary";
                followFocusedScreen = false;
                fontWeight = "bold";
                groupedBorderOpacity = 1;
                hideUnoccupied = true;
                iconScale = 0.8;
                id = "Workspace";
                labelMode = "none";
                occupiedColor = "secondary";
                pillSize = 0.6;
                showApplications = false;
                showApplicationsHover = false;
                showBadge = true;
                showLabelsOnlyWhenOccupied = true;
                unfocusedIconsOpacity = 1;
              }
            ];
            right = [
              {
                deviceNativePath = "__default__";
                displayMode = "graphic-clean";
                hideIfIdle = false;
                hideIfNotDetected = true;
                id = "Battery";
                showNoctaliaPerformance = true;
                showPowerProfiles = true;
              }
              {
                displayMode = "onhover";
                iconColor = "none";
                id = "Network";
                textColor = "none";
              }
              {
                displayMode = "onhover";
                iconColor = "none";
                id = "Bluetooth";
                textColor = "none";
              }
              {
                displayMode = "onhover";
                iconColor = "none";
                id = "Volume";
                middleClickCommand = "pwvucontrol || pavucontrol";
                textColor = "none";
              }
              {
                clockColor = "none";
                customFont = "";
                formatHorizontal = "HH:mm ddd, MMM dd";
                formatVertical = "HH mm - dd MM";
                id = "Clock";
                tooltipFormat = "HH:mm ddd, MMM dd";
                useCustomFont = false;
              }
              {
                hideWhenZero = true;
                hideWhenZeroUnread = false;
                iconColor = "none";
                id = "NotificationHistory";
                showUnreadBadge = true;
                unreadBadgeColor = "primary";
              }
              {
                defaultSettings = {
                  audioCodec = "opus";
                  audioSource = "default_output";
                  colorRange = "limited";
                  copyToClipboard = false;
                  customReplayDuration = "30";
                  directory = "";
                  filenamePattern = "recording_yyyyMMdd_HHmmss";
                  frameRate = "60";
                  hideInactive = true;
                  iconColor = "none";
                  quality = "very_high";
                  replayDuration = "30";
                  replayEnabled = false;
                  replayStorage = "ram";
                  resolution = "original";
                  restorePortalSession = false;
                  showCursor = true;
                  videoCodec = "h264";
                  videoSource = "portal";
                };
                id = "plugin:screen-recorder";
              }
            ];
          };
        };
        brightness = {
          backlightDeviceMappings = [ ];
          brightnessStep = 5;
          enableDdcSupport = true;
          enforceMinimum = true;
        };
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = false;
              id = "weather-card";
            }
          ];
        };
        colorSchemes = {
          darkMode = true;
          generationMethod = "tonal-spot";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          monitorForColors = "";
          predefinedScheme = "Tokyo Night";
          schedulingMode = "off";
          useWallpaperColors = false;
        };
        controlCenter = {
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = false;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
          diskPath = "/";
          position = "close_to_bar_button";
          shortcuts = {
            left = [
              { id = "WallpaperSelector"; }
              { id = "NoctaliaPerformance"; }
              { id = "KeepAwake"; }
              { id = "PowerProfile"; }
            ];
            right = [
              { id = "NightLight"; }
              {
                defaultSettings = {
                  audioCodec = "opus";
                  audioSource = "default_output";
                  colorRange = "limited";
                  copyToClipboard = false;
                  customReplayDuration = "30";
                  directory = "";
                  filenamePattern = "recording_yyyyMMdd_HHmmss";
                  frameRate = "60";
                  hideInactive = false;
                  iconColor = "none";
                  quality = "very_high";
                  replayDuration = "30";
                  replayEnabled = false;
                  replayStorage = "ram";
                  resolution = "original";
                  restorePortalSession = false;
                  showCursor = true;
                  videoCodec = "h264";
                  videoSource = "portal";
                };
                id = "plugin:screen-recorder";
              }
              {
                defaultSettings = {
                  colorHistory = [ ];
                  installedLangs = [
                    "eng"
                    "spa"
                  ];
                  paletteColors = [ ];
                  selectedOcrLang = "eng";
                  transAvailable = false;
                };
                id = "plugin:screen-toolkit";
              }
            ];
          };
        };
        desktopWidgets = {
          enabled = false;
          gridSnap = false;
          gridSnapScale = false;
          monitorWidgets = [ ];
          overviewEnabled = true;
        };
        dock = {
          animationSpeed = 1;
          backgroundOpacity = 1;
          colorizeIcons = false;
          deadOpacity = 0.6;
          displayMode = "auto_hide";
          dockType = "floating";
          enabled = false;
          floatingRatio = 1;
          groupApps = false;
          groupClickAction = "cycle";
          groupContextMenuMode = "extended";
          groupIndicatorStyle = "dots";
          inactiveIndicators = false;
          indicatorColor = "primary";
          indicatorOpacity = 0.6;
          indicatorThickness = 3;
          launcherIconColor = "none";
          launcherPosition = "end";
          monitors = [ ];
          onlySameOutput = true;
          pinnedApps = [ ];
          pinnedStatic = false;
          position = "bottom";
          showDockIndicator = false;
          showLauncherIcon = false;
          sitOnFrame = false;
          size = 1;
        };
        general = {
          allowPanelsOnScreenWithoutBar = true;
          allowPasswordWithFprintd = true;
          animationDisabled = false;
          animationSpeed = 1;
          autoStartAuth = true;
          avatarImage = "";
          boxRadiusRatio = 1;
          clockFormat = "hh\nmm";
          clockStyle = "custom";
          compactLockScreen = true;
          dimmerOpacity = 0;
          enableBlurBehind = true;
          enableLockScreenCountdown = true;
          enableLockScreenMediaControls = false;
          enableShadows = false;
          forceBlackScreenCorners = true;
          iRadiusRatio = 1;
          keybinds = {
            keyDown = [ "Down" ];
            keyEnter = [
              "Return"
              "Enter"
            ];
            keyEscape = [ "Esc" ];
            keyLeft = [ "Left" ];
            keyRemove = [ "Del" ];
            keyRight = [ "Right" ];
            keyUp = [ "Up" ];
          };
          language = "";
          lockOnSuspend = true;
          lockScreenAnimations = false;
          lockScreenBlur = 0;
          lockScreenCountdownDuration = 10000;
          lockScreenMonitors = [ ];
          lockScreenTint = 0;
          passwordChars = false;
          radiusRatio = 0.61;
          reverseScroll = false;
          scaleRatio = 1;
          screenRadiusRatio = 0.6;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          showChangelogOnStartup = true;
          showHibernateOnLockScreen = true;
          showScreenCorners = true;
          showSessionButtonsOnLockScreen = true;
          telemetryEnabled = false;
        };
        hooks = {
          darkModeChange = "";
          enabled = false;
          performanceModeDisabled = "";
          performanceModeEnabled = "";
          screenLock = "";
          screenUnlock = "";
          session = "";
          startup = "";
          wallpaperChange = "";
        };
        idle = {
          customCommands = "[]";
          enabled = true;
          fadeDuration = 7;
          lockCommand = "";
          lockTimeout = 660;
          resumeLockCommand = "";
          resumeScreenOffCommand = "";
          resumeSuspendCommand = "";
          screenOffCommand = "";
          screenOffTimeout = 600;
          suspendCommand = "";
          suspendTimeout = 1800;
        };
        location = {
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
          hideWeatherCityName = false;
          hideWeatherTimezone = false;
          name = "Tokyo";
          showCalendarEvents = true;
          showCalendarWeather = true;
          showWeekNumberInCalendar = false;
          use12hourFormat = true;
          useFahrenheit = false;
          weatherEnabled = false;
          weatherShowEffects = true;
        };
        network = {
          airplaneModeEnabled = false;
          bluetoothAutoConnect = true;
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = true;
          bluetoothRssiPollIntervalMs = 60000;
          bluetoothRssiPollingEnabled = false;
          disableDiscoverability = true;
          networkPanelView = "wifi";
          wifiDetailsViewMode = "grid";
          wifiEnabled = true;
        };
        nightLight = {
          autoSchedule = false;
          dayTemp = "6500";
          enabled = true;
          forced = false;
          manualSunrise = "07:00";
          manualSunset = "18:30";
          nightTemp = "4000";
        };
        noctaliaPerformance = {
          disableDesktopWidgets = true;
          disableWallpaper = true;
        };
        notifications = {
          backgroundOpacity = 1;
          clearDismissed = true;
          criticalUrgencyDuration = 15;
          density = "default";
          enableBatteryToast = true;
          enableKeyboardLayoutToast = true;
          enableMarkdown = true;
          enableMediaToast = false;
          enabled = true;
          location = "top_right";
          lowUrgencyDuration = 2;
          monitors = [
            "eDP-1"
            "DP-4"
          ];
          normalUrgencyDuration = 4;
          overlayLayer = true;
          respectExpireTimeout = false;
          saveToHistory = {
            critical = true;
            low = true;
            normal = true;
          };
          sounds = {
            criticalSoundFile = "";
            enabled = true;
            excludedApps = "discord,firefox,chrome,chromium,edge";
            lowSoundFile = "";
            normalSoundFile = "";
            separateSounds = false;
            volume = 0.5;
          };
        };
        osd = {
          autoHideMs = 2000;
          backgroundOpacity = 1;
          enabled = true;
          enabledTypes = [
            0
            1
            2
            3
          ];
          location = "top_right";
          monitors = [ ];
          overlayLayer = true;
        };
        plugins = {
          autoUpdate = false;
        };
        sessionMenu = {
          countdownDuration = 5000;
          enableCountdown = true;
          largeButtonsLayout = "single-row";
          largeButtonsStyle = false;
          position = "top_center";
          powerOptions = [
            {
              action = "lock";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "1";
            }
            {
              action = "suspend";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "2";
            }
            {
              action = "hibernate";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "3";
            }
            {
              action = "reboot";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "4";
            }
            {
              action = "logout";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "5";
            }
            {
              action = "shutdown";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "6";
            }
            {
              action = "userspaceReboot";
              command = "";
              countdownEnabled = true;
              enabled = false;
              keybind = "";
            }
            {
              action = "rebootToUefi";
              command = "";
              countdownEnabled = true;
              enabled = true;
              keybind = "7";
            }
          ];
          showHeader = true;
          showKeybinds = true;
        };
        settingsVersion = 57;
        systemMonitor = {
          batteryCriticalThreshold = 5;
          batteryWarningThreshold = 20;
          cpuCriticalThreshold = 90;
          cpuWarningThreshold = 80;
          criticalColor = "#f7768e";
          diskAvailCriticalThreshold = 10;
          diskAvailWarningThreshold = 20;
          diskCriticalThreshold = 90;
          diskWarningThreshold = 80;
          enableDgpuMonitoring = false;
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          gpuCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          memCriticalThreshold = 90;
          memWarningThreshold = 80;
          swapCriticalThreshold = 90;
          swapWarningThreshold = 80;
          tempCriticalThreshold = 90;
          tempWarningThreshold = 75;
          useCustomColors = false;
          warningColor = "#9ece6a";
        };
        templates = {
          activeTemplates = [ ];
          enableUserTheming = false;
        };
        ui = {
          boxBorderEnabled = false;
          fontDefault = "JetBrainsMono Nerd Font";
          fontDefaultScale = 0.95;
          fontFixed = "JetBrainsMono Nerd Font Mono";
          fontFixedScale = 0.95;
          panelBackgroundOpacity = 1;
          panelsAttachedToBar = false;
          scrollbarAlwaysVisible = false;
          settingsPanelMode = "centered";
          settingsPanelSideBarCardStyle = false;
          tooltipsEnabled = true;
          translucentWidgets = true;
        };
        wallpaper = {
          automationEnabled = false;
          directory = "${self.lib.resourcesPath}/wallpapers";
          enableMultiMonitorDirectories = false;
          enabled = true;
          favorites = [ ];
          fillColor = "#000000";
          fillMode = "fill";
          hideWallpaperFilenames = false;
          monitorDirectories = [ ];
          overviewBlur = 0.4;
          overviewEnabled = true;
          overviewTint = 0.6;
          panelPosition = "follow_bar";
          randomIntervalSec = 300;
          setWallpaperOnAllMonitors = true;
          showHiddenFiles = false;
          skipStartupTransition = false;
          solidColor = "#1a1a2e";
          sortOrder = "name";
          transitionDuration = 1500;
          transitionEdgeSmoothness = 0.05;
          transitionType = "random";
          useSolidColor = false;
          useWallhaven = false;
          viewMode = "single";
          wallhavenApiKey = "";
          wallhavenCategories = "111";
          wallhavenOrder = "desc";
          wallhavenPurity = "100";
          wallhavenQuery = "";
          wallhavenRatios = "";
          wallhavenResolutionHeight = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenSorting = "relevance";
          wallpaperChangeMode = "random";
        };
        state = {
          barVisible = true;
          changelogState = {
            lastSeenVersion = "v4.6.7";
          };
          colorSchemesList = {
            schemes = [ ];
            timestamp = 0;
          };
          desktopWidgetsEditMode = false;
          display = {
            DP-3 = {
              connected = true;
              height = 1080;
              name = "DP-3";
              physical_height = 300;
              physical_width = 530;
              refresh_rate = 143981;
              scale = 1;
              transform = "Normal";
              vrr_enabled = true;
              vrr_supported = true;
              width = 1920;
              x = 0;
              y = 0;
            };
            HDMI-A-2 = {
              connected = true;
              height = 1440;
              name = "HDMI-A-2";
              physical_height = 340;
              physical_width = 600;
              refresh_rate = 74932;
              scale = 1;
              transform = "Normal";
              vrr_enabled = false;
              vrr_supported = false;
              width = 2560;
              x = -2560;
              y = 0;
            };
          };
          doNotDisturb = false;
          lockScreenActive = false;
          noctaliaPerformanceMode = false;
          notificationsState = {
            lastSeenTs = 1774862674000;
          };
          openedPanel = "";
          ui = {
            settingsSidebarExpanded = true;
          };
          wallpapers = {
            DP-3 = "/nix/store/mlycm49bx2qh96q4df1sm4gswj5fsj2h-wallpapers/wallhaven.jpg";
            HDMI-A-2 = "/nix/store/mlycm49bx2qh96q4df1sm4gswj5fsj2h-wallpapers/wallhaven.jpg";
          };
        };
      };
    };
  };
}
