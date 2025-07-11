{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = true;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = true;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
            # Base tools
            pkgs.neovim
            pkgs.wget

            pkgs.openconnect # Cisco AnyConnect client
            pkgs.vpn-slice # easy and secure split-tunnel VPN setup
            pkgs.tokei # Line of code statistics tool


        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "clement";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "shpotify"
          "tailscale"
          "texlive"
        ];
        casks = [
          "aldente"
          "docker-desktop"
          "karabiner-elements"
          "the-unarchiver"
          "figma"
          "mountain-duck"
          "twingate"
          "audacity"
          "firefox"
          "libreoffice"
          "nextcloud"
          "usbimager"
          "balenaetcher"
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
          "blender"
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
          "spotify"
          "discord"
          "inkscape"
          "minecraft"
          "sublime-text"
          #"docker"
          "jetbrains-toolbox"
          #"mongodb-compass"
          "termius"
        ];
#        masApps = [
#        ];
        onActivation.cleanup = "zap";
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mbp
    darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "clement";

            autoMigrate = true;

            # Optional: Declarative tap management
            taps = {
              "homebrew/core" = homebrew-core;
              "homebrew/cask" = homebrew-cask;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      ];
    };
  };
}
