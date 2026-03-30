{ self, ... }: 

{ 

  flake.wrappers.noctalia = { wlib, pkgs, ... }:
  {
    imports = [ wlib.wrapperModules.noctalia-shell ];
    
    config = let
      noctalia-plugins = pkgs.fetchgit {
        url = "https://github.com/noctalia-dev/noctalia-plugins";
        rev = "e56dcb6b4c7a680282d0279076a82754397d1fd5";
        sha256 = "sha256-TNwt8BkZSmI62BwBgNdKaOiWX8ePyrJsxsPCcF4z660=";
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
        settingsVersion = 59;
        bar = {
          barType = "floating";
          position = "top";
          monitors = [ ];
          density = "compact";
          showOutline = false;
          showCapsule = false;
          capsuleOpacity = 1;
          capsuleColorKey = "none";
          widgetSpacing = 6;
          contentPadding = 2;
          fontScale = 1;
          enableExclusionZoneInset = true;
          backgroundOpacity = 0;
          useSeparateOpacity = true;
          marginVertical = 5;
          marginHorizontal = 5;
          frameThickness = 8;
          frameRadius = 12;
          outerCorners = true;
          hideOnOverview = false;
          displayMode = "always_visible";
          autoHideDelay = 500;
          autoShowDelay = 150;
          showOnWorkspaceSwitch = true;
          widgets = {
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
            right = [
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
          mouseWheelAction = "none";
          reverseScroll = false;
          mouseWheelWrap = true;
          middleClickAction = "none";
          middleClickFollowMouse = false;
          middleClickCommand = "";
          rightClickAction = "controlCenter";
          rightClickFollowMouse = true;
          rightClickCommand = "";
          screenOverrides = [ ];
        };
        general = {
          avatarImage = "";
          dimmerOpacity = 0;
          showScreenCorners = true;
          forceBlackScreenCorners = true;
          scaleRatio = 1;
          radiusRatio = 0.61;
          iRadiusRatio = 1;
          boxRadiusRatio = 1;
          screenRadiusRatio = 0.6;
          animationSpeed = 1;
          animationDisabled = false;
          compactLockScreen = true;
          lockScreenAnimations = false;
          lockOnSuspend = true;
          showSessionButtonsOnLockScreen = true;
          showHibernateOnLockScreen = true;
          enableLockScreenMediaControls = false;
          enableShadows = false;
          enableBlurBehind = true;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          language = "";
          allowPanelsOnScreenWithoutBar = true;
          showChangelogOnStartup = true;
          telemetryEnabled = false;
          enableLockScreenCountdown = true;
          lockScreenCountdownDuration = 10000;
          autoStartAuth = true;
          allowPasswordWithFprintd = true;
          clockStyle = "custom";
          clockFormat = "hh\nmm";
          passwordChars = false;
          lockScreenMonitors = [ ];
          lockScreenBlur = 0;
          lockScreenTint = 0;
          keybinds = {
            keyUp = [
              "Up"
            ];
            keyDown = [
              "Down"
            ];
            keyLeft = [
              "Left"
            ];
            keyRight = [
              "Right"
            ];
            keyEnter = [
              "Return"
              "Enter"
            ];
            keyEscape = [
              "Esc"
            ];
            keyRemove = [
              "Del"
            ];
          };
          reverseScroll = false;
          smoothScrollEnabled = true;
        };
        ui = {
          fontDefault = "JetBrainsMono Nerd Font";
          fontFixed = "JetBrainsMono Nerd Font Mono";
          fontDefaultScale = 0.95;
          fontFixedScale = 0.95;
          tooltipsEnabled = true;
          scrollbarAlwaysVisible = false;
          boxBorderEnabled = false;
          panelBackgroundOpacity = 1;
          translucentWidgets = true;
          panelsAttachedToBar = false;
          settingsPanelMode = "centered";
          settingsPanelSideBarCardStyle = false;
        };
        location = {
          name = "Tokyo";
          weatherEnabled = false;
          weatherShowEffects = true;
          useFahrenheit = false;
          use12hourFormat = true;
          showWeekNumberInCalendar = false;
          showCalendarEvents = true;
          showCalendarWeather = true;
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
          hideWeatherTimezone = false;
          hideWeatherCityName = false;
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
        wallpaper = {
          enabled = true;
          overviewEnabled = true;
          directory = "${self.lib.resourcesPath}/wallpapers";
          monitorDirectories = [ ];
          enableMultiMonitorDirectories = false;
          showHiddenFiles = false;
          viewMode = "single";
          setWallpaperOnAllMonitors = true;
          fillMode = "fill";
          fillColor = "#000000";
          useSolidColor = false;
          solidColor = "#1a1a2e";
          automationEnabled = false;
          wallpaperChangeMode = "random";
          randomIntervalSec = 300;
          transitionDuration = 1500;
          transitionType = [
            "fade"
            "disc"
            "stripes"
            "wipe"
            "pixelate"
            "honeycomb"
          ];
          skipStartupTransition = false;
          transitionEdgeSmoothness = 0.05;
          panelPosition = "follow_bar";
          hideWallpaperFilenames = false;
          useOriginalImages = false;
          overviewBlur = 0.4;
          overviewTint = 0.6;
          useWallhaven = false;
          wallhavenQuery = "";
          wallhavenSorting = "relevance";
          wallhavenOrder = "desc";
          wallhavenCategories = "111";
          wallhavenPurity = "100";
          wallhavenRatios = "";
          wallhavenApiKey = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenResolutionHeight = "";
          sortOrder = "name";
          favorites = [ ];
        };
        appLauncher = {
          enableClipboardHistory = true;
          autoPasteClipboard = false;
          enableClipPreview = true;
          clipboardWrapText = true;
          enableClipboardSmartIcons = true;
          enableClipboardChips = true;
          clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
          clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
          position = "top_center";
          pinnedApps = [ ];
          sortByMostUsed = true;
          terminalCommand = "kitty -e";
          customLaunchPrefixEnabled = false;
          customLaunchPrefix = "";
          viewMode = "list";
          showCategories = true;
          iconMode = "tabler";
          showIconBackground = false;
          enableSettingsSearch = true;
          enableWindowsSearch = true;
          enableSessionSearch = true;
          ignoreMouseInput = false;
          screenshotAnnotationTool = "";
          overviewLayer = true;
          density = "compact";
        };
        controlCenter = {
          position = "close_to_bar_button";
          diskPath = "/";
          shortcuts = {
            left = [
              {
                id = "WallpaperSelector";
              }
              {
                id = "NoctaliaPerformance";
              }
              {
                id = "KeepAwake";
              }
            ];
            right = [
              {
                id = "NightLight";
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
        };
        systemMonitor = {
          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;
          tempWarningThreshold = 75;
          tempCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          gpuCriticalThreshold = 90;
          memWarningThreshold = 80;
          memCriticalThreshold = 90;
          swapWarningThreshold = 80;
          swapCriticalThreshold = 90;
          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          diskAvailWarningThreshold = 20;
          diskAvailCriticalThreshold = 10;
          batteryWarningThreshold = 20;
          batteryCriticalThreshold = 5;
          enableDgpuMonitoring = false;
          useCustomColors = false;
          warningColor = "#9ece6a";
          criticalColor = "#f7768e";
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        };
        noctaliaPerformance = {
          disableWallpaper = true;
          disableDesktopWidgets = true;
        };
        dock = {
          enabled = false;
          position = "bottom";
          displayMode = "auto_hide";
          dockType = "floating";
          backgroundOpacity = 1;
          floatingRatio = 1;
          size = 1;
          onlySameOutput = true;
          monitors = [ ];
          pinnedApps = [ ];
          colorizeIcons = false;
          showLauncherIcon = false;
          launcherPosition = "end";
          launcherUseDistroLogo = false;
          launcherIcon = "";
          launcherIconColor = "none";
          pinnedStatic = false;
          inactiveIndicators = false;
          groupApps = false;
          groupContextMenuMode = "extended";
          groupClickAction = "cycle";
          groupIndicatorStyle = "dots";
          deadOpacity = 0.6;
          animationSpeed = 1;
          sitOnFrame = false;
          showDockIndicator = false;
          indicatorThickness = 3;
          indicatorColor = "primary";
          indicatorOpacity = 0.6;
        };
        network = {
          airplaneModeEnabled = false;
          bluetoothRssiPollingEnabled = false;
          bluetoothRssiPollIntervalMs = 60000;
          networkPanelView = "wifi";
          wifiDetailsViewMode = "grid";
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = true;
          disableDiscoverability = true;
          bluetoothAutoConnect = true;
        };
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 5000;
          position = "top_center";
          showHeader = true;
          showKeybinds = true;
          largeButtonsStyle = false;
          largeButtonsLayout = "single-row";
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
        };
        notifications = {
          enabled = true;
          enableMarkdown = true;
          density = "default";
          monitors = [
            "eDP-1"
            "DP-4"
          ];
          location = "top_right";
          overlayLayer = true;
          backgroundOpacity = 1;
          respectExpireTimeout = false;
          lowUrgencyDuration = 2;
          normalUrgencyDuration = 4;
          criticalUrgencyDuration = 15;
          clearDismissed = true;
          saveToHistory = {
            low = true;
            normal = true;
            critical = true;
          };
          sounds = {
            enabled = true;
            volume = 0.5;
            separateSounds = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile = "";
            excludedApps = "discord,firefox,chrome,chromium,edge";
          };
          enableMediaToast = false;
          enableKeyboardLayoutToast = true;
          enableBatteryToast = true;
        };
        osd = {
          enabled = true;
          location = "top_right";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 1;
          enabledTypes = [
            0
            1
            2
            3
          ];
          monitors = [ ];
        };
        audio = {
          volumeStep = 5;
          volumeOverdrive = false;
          spectrumFrameRate = 30;
          visualizerType = "linear";
          spectrumMirrored = true;
          mprisBlacklist = [ ];
          preferredPlayer = "spotify";
          volumeFeedback = false;
          volumeFeedbackSoundFile = "";
        };
        brightness = {
          brightnessStep = 5;
          enforceMinimum = true;
          enableDdcSupport = true;
          backlightDeviceMappings = [ ];
        };
        colorSchemes = {
          useWallpaperColors = false;
          predefinedScheme = "Tokyo Night";
          darkMode = true;
          schedulingMode = "off";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          generationMethod = "tonal-spot";
          monitorForColors = "";
          syncGsettings = true;
        };
        templates = {
          activeTemplates = [ ];
          enableUserTheming = false;
        };
        nightLight = {
          enabled = true;
          forced = false;
          autoSchedule = false;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "07:00";
          manualSunset = "18:30";
        };
        hooks = {
          enabled = false;
          wallpaperChange = "";
          darkModeChange = "";
          screenLock = "";
          screenUnlock = "";
          performanceModeEnabled = "";
          performanceModeDisabled = "";
          startup = "";
          session = "";
          colorGeneration = "";
        };
        plugins = {
          autoUpdate = false;
          notifyUpdates = true;
        };
        idle = {
          enabled = true;
          screenOffTimeout = 600;
          lockTimeout = 660;
          suspendTimeout = 1800;
          fadeDuration = 7;
          screenOffCommand = "";
          lockCommand = "";
          suspendCommand = "";
          resumeScreenOffCommand = "";
          resumeLockCommand = "";
          resumeSuspendCommand = "";
          customCommands = "[]";
        };
        desktopWidgets = {
          enabled = false;
          overviewEnabled = true;
          gridSnap = false;
          gridSnapScale = false;
          monitorWidgets = [ ];
        };
      };
    };
  };
}
