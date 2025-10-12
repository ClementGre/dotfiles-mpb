# Rebuild: sudo darwin-rebuild switch --flake ~/GitHub/dotfiles-MBP/
# Update: nix flake update
{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    felixkratz = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, mac-app-util, homebrew-core, homebrew-cask, home-manager, felixkratz }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [
            # Base tools
            neovim
            wget
            ffmpeg_6-full
            nix-index
            cowsay
            lolcat
            python314
            python310
            fortune
            nmap
            arp-scan
            typst
            poetry # Python dependency management
            comma # Run nix packages without installing them with `, <package>`
            fastfetch
            fish # Shell
            duti # Manage file associations
            maven

            openconnect # Cisco AnyConnect client
            vpn-slice # easy and secure split-tunnel VPN setup
            tokei # Line of code statistics tool
            libpq # PostgreSQL client library


            skhd # Simple hotkey daemon for macOS
            yabai # macOS window manager
            jq # commandline json processor

            libpq.pg_config

            nodejs_24

            # GUI apps
            audacity
            inkscape-with-extensions
            #blender
            spotify
        ];

      fonts = {
        packages = with pkgs; [
            inter
        ];
      };

      nixpkgs.config.allowUnfree = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      system.primaryUser = "clement";

      security.pam.services.sudo_local.text = "auth sufficient pam_tid.so.2";
      security.sudo.extraConfig = ''
          clement ALL=(ALL) NOPASSWD: /usr/bin/wdutil info
        '';

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "shpotify"
          "tailscale"
          "texlive"
          "ifstat"
          "ical-buddy"
          "sketchybar"
        ];
        casks = [
          "aldente"
          "docker-desktop"
          "karabiner-elements"
          "the-unarchiver"
          "figma"
          "mountain-duck"
          "twingate"
          #"audacity"
          "firefox"
          "libreoffice"
          "nextcloud"
          "usbimager"
          #"balenaetcher"
          "font-computer-modern"
          "lm-studio"
          "notion"
          "visual-studio-code"
          "beeper"
          "font-jetbrains-mono"
          "logoer"
          "numi"
          "font-new-computer-modern"
          "obsidian"
          "warp"
          "bitwarden"
          "font-sf-pro"
          "maccy"
          "windows-app"
          #"blender"
          "free-ruler"
          "mathpix-snipping-tool"
          "phoenix"
          "zen"
          "busycal"
          "hammerspoon"
          "microsoft-auto-update"
          "postman"
          "chromium"
          #"handbrake"
          "microsoft-excel"
          "qflipper"
          "zoom"
          "coolterm"
          "handbrake-app"
          "microsoft-powerpoint"
          "rectangle"
          "cyberduck"
          "iina"
          "microsoft-word"
          #"spotify"
          "discord"
          #"inkscape"
          "minecraft"
          "sublime-text"
          #"docker"
          "jetbrains-toolbox"
          #"mongodb-compass"
          "termius"
          "bepo"
          # Fonts
          "font-hack-nerd-font"
          "sf-symbols"
        ];
        masApps = {
          reMarkableDesktop = 1276493162;
          PixelmatorPro = 1289583905;
          ColorSlurp = 1287239339;
          Dropover = 1355679052;
          ParallelsDesktop = 1085114709;
          Vivid = 6443470555;
          HandMirror = 1502839586;
          LittleSnitchMini = 1629008763;
          Amphetamine = 937984704;
          #BarbeeHideMenuBarItems = 1548711022;
          #ScreenBandit = 1043565969;
          #SpoticaMenu = 570549457;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
          NSGlobalDomain = {
            AppleFontSmoothing = 2;
            NSAutomaticSpellingCorrectionEnabled = false;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            AppleEnableSwipeNavigateWithScrolls = false;
            AppleMeasurementUnits = "Centimeters";
            AppleICUForce24HourTime = true;
            "com.apple.mouse.tapBehavior" = 1;
          };

          dock = {
            autohide = true;
            autohide-delay = 0.05;
            autohide-time-modifier = 0.5;
            mru-spaces = false;
            persistent-others = ["/Users/clement/Downloads"];
            scroll-to-open = true;
            minimize-to-application = true;
            show-recents = false;
            static-only = false;
            tilesize = 48;
            largesize = 68;
            wvous-br-corner = 10;
            wvous-bl-corner = 1;
            wvous-tr-corner = 1;
            wvous-tl-corner = 1;
            persistent-apps = [
              { app = "/System/Applications/Preview.app"; }
              { spacer = { small = true; }; }
              { app = "/System/Applications/Mail.app"; }
              { app = "/Applications/Beeper Desktop.app"; }
              { app = "/Applications/Discord.app"; }
              #{ app = "/Applications/Element.app"; }
              { app = "${pkgs.spotify}/Applications/Spotify.app"; }
              { spacer = { small = true; }; }
              { app = "/Applications/Anytype.app"; }
              { app = "/Applications/BusyCal.app"; }
              { app = "/Applications/Microsoft Word.app"; }
              { app = "/Applications/Microsoft Excel.app"; }
              { app = "/Applications/Microsoft PowerPoint.app"; }
              { app = "/Applications/LibreOffice.app"; }
              { app = "/Applications/reMarkable.app"; }
              { app = "/Applications/Termius.app"; }
              { app = "/System/Applications/Utilities/Terminal.app"; }
              { app = "/Applications/Sublime Text.app"; }
              { spacer = { small = true; }; }
              { app = "/Applications/Zen.app"; }
              { spacer = { small = true; }; }
              { app = "/Users/clement/Applications/IntelliJ IDEA Ultimate.app"; }
              { app = "/Users/clement/Applications/PyCharm.app"; }
              { app = "/Users/clement/Applications/CLion.app"; }
            ];
          };
          finder = {
            AppleShowAllExtensions = true;
            FXEnableExtensionChangeWarning = false;
            NewWindowTarget = "Other";
            NewWindowTargetPath = "file:///Users/clement/Downloads";
            #AppleShowAllFiles = true;
            ShowPathbar = true;
            CreateDesktop = false;
          };
          loginwindow = {
            GuestEnabled = false;
            DisableConsoleAccess = true;
          };
          trackpad = {
            FirstClickThreshold = 0;
            SecondClickThreshold = 0;
            TrackpadThreeFingerDrag = true;
          };
          WindowManager = {
            EnableTilingByEdgeDrag = false;
          };
          LaunchServices.LSQuarantine = false;
          spaces.spans-displays = false;
        };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .
    darwinConfigurations."MBP-Clement" = nix-darwin.lib.darwinSystem  {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
#          services = {
#            sketchybar = {
#              enable = true;
#              #package = pkgs.sketchybar;
#            };
#            skhd.enable = true;
#          };
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "clement";

            autoMigrate = true;

            # Optional: Declarative tap management
            taps = {
              "homebrew/core" = homebrew-core;
              "homebrew/cask" = homebrew-cask;
              "FelixKratz/homebrew-formulae" = felixkratz;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
        home-manager.darwinModules.home-manager {
          users.users.clement.home = /Users/clement;
          home-manager.backupFileExtension = "backup";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.clement = import ./home.nix;
        }
      ];
    };
  };
}
