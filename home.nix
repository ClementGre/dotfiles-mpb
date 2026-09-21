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

  # Custom icons and file associations are `just icons` / `just assoc`, not run on every switch
  home.activation.startupCommands = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      ${./scripts/startup-commands.sh}
    '';
  };
}
