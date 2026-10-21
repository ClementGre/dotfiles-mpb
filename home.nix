# home.nix
# home-manager switch

{ config, pkgs, ... }:

let
  # Symlink straight to the repo (not a store copy), so edits apply without a rebuild
  link = path: config.lib.file.mkOutOfStoreSymlink "/Users/clement/GitHub/dotfiles-MBP/files/${path}";
in
{

  home.username = "clement";
  #home.homeDirectory = "/Users/clement";
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".zshenv".source = link "zsh/.zshenv";
    ".zprofile".source = link "zsh/.zprofile";
    ".zshrc".source = link "zsh/.zshrc";
    ".zlogin".source = link "zsh/.zlogin";
    ".config/fastfetch/config.jsonc".source = link "fastfetch/config.jsonc";
    ".skhdrc".source = link "skhd/.skhdrc";
    ".config/sketchybar".source = link "sketchybar";
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;

  # Réglages > Barre des menus > Afficher l'arrière-plan de la barre des menus, so the native
  # bar doesn't blend into sketchybar when revealed
  targets.darwin.defaults.NSGlobalDomain.SLSMenuBarUseBlurredAppearance = true;

  # macOS 27's Live Activities renderer leaks (2+ GB, 100-200% CPU after a few hours) and lags
  # every animation, even with no widgets. Kill it when it misbehaves, launchd respawns it clean
  launchd.agents.widget-watchdog = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.writeShellScript "widget-watchdog" ''
          # A fresh one idles at ~2% CPU and ~50 MB resident (Activity Monitor shows ~130 MB, its
          # footprint counts GPU surfaces), so above 10% or 100 MB it already started leaking
          state="$HOME/Library/Caches/widget-watchdog"
          now=$(date +%s)
          read -r last_pid last_cs last_time 2>/dev/null < "$state"
          ps -Axo pid=,time=,rss=,comm= | while read -r pid time rss comm; do
            [[ "$comm" == */WidgetRenderer_Activities ]] || continue
            # CPU time used since the last run (pcpu is a decaying average, way too noisy).
            # time is minutes:seconds.hundredths, rss is in KB
            minutes=''${time%%:*} seconds=''${time#*:}
            cs=$(( 10#$minutes * 6000 + 10#''${seconds/./} ))
            cpu=0
            if [[ "$pid" == "$last_pid" ]] && (( now > last_time )); then
              cpu=$(( (cs - last_cs) / (now - last_time) ))
            fi
            echo "$pid $cs $now" > "$state"
            if (( cpu > 10 || rss > 102400 )); then
              echo "$(date '+%F %T') killed $pid (cpu ''${cpu}%, rss $(( rss / 1024 )) MB)"
              kill -9 "$pid"
            fi
          done
        ''}"
      ];
      StartInterval = 60;
      RunAtLoad = true;
      StandardOutPath = "/Users/clement/Library/Logs/widget-watchdog.log";
      StandardErrorPath = "/Users/clement/Library/Logs/widget-watchdog.log";
    };
  };

  # Réglages > Spotlight: no result category shown (Raycast is the launcher, it still searches
  # the index) and no clipboard history (Raycast has its own)
  targets.darwin.defaults."com.apple.Spotlight" = {
    PasteboardHistoryEnabled = false;
    # Despite the name, the categories turned off
    EnabledPreferenceRules = [
      "Custom.relatedContents"
      "com.apple.AppStore"
      "com.apple.tips"
      "com.busymac.busycal3"
      "com.apple.calculator"
      "com.apple.iCal"
      "com.anthropic.claudefordesktop"
      "com.apple.AddressBook"
      "com.apple.VoiceMemos"
      "com.apple.Dictionary"
      "com.hnc.Discord"
      "com.apple.clock"
      "com.apple.iBooksX"
      "com.apple.mail"
      "com.apple.MobileSMS"
      "com.microsoft.Excel"
      "com.microsoft.Powerpoint"
      "com.microsoft.Word"
      "com.apple.Music"
      "com.apple.Notes"
      "com.apple.Photos"
      "com.apple.podcasts"
      "com.apple.shortcuts"
      "com.apple.reminders"
      "com.apple.systempreferences"
      "com.apple.Safari"
      "com.apple.mobilephone"
      "com.microsoft.rdc.macos"
      "System.applications"
      "System.iphoneApps"
      "System.folders"
      "System.files"
      "System.menuItems"
    ];
  };

  # Code folders change constantly (builds, node_modules, git objects) and keep mds re-indexing.
  # Excluded folders are not indexed at all, so Raycast's File Search won't find them either
  home.activation.spotlightExclusions = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      ${pkgs.runCommandCC "spotlight-exclude" { } "$CC -O2 ${./scripts/spotlight-exclude.c} -framework CoreFoundation -o $out"} \
        ~/Code ~/SIA ~/CodeIF ~/Gitea ~/GitHub
    '';
  };

  # Custom icons and file associations are `just icons` / `just assoc`, not run on every switch
  home.activation.startupCommands = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      ${./scripts/startup-commands.sh}
    '';
  };
}
