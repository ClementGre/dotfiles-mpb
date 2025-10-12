# home.nix
# home-manager switch

{ config, pkgs, ... }:

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
    ".zshenv".source = ./files/zsh/.zshenv;
    ".zprofile".source = /Users/clement/GitHub/dotfiles-MBP/files/zsh/.zprofile;
    ".zshrc".source = /Users/clement/GitHub/dotfiles-MBP/files/zsh/.zshrc;
    ".zlogin".source = /Users/clement/GitHub/dotfiles-MBP/files/zsh/.zlogin;
    ".config/fastfetch/config.jsonc".source = /Users/clement/GitHub/dotfiles-MBP/files/fastfetch/config.jsonc;
    ".skhdrc".source = /Users/clement/GitHub/dotfiles-MBP/files/skhd/.skhdrc;
    ".config/sketchybar".source = /Users/clement/GitHub/dotfiles-MBP/files/sketchybar;
    ".config/sketchybar".executable = true;

  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;

    home.activation.fileAssociations = {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
       ${./scripts/file-associations.sh}
      '';
    };

    home.activation.startupCommands = {
      after = [ "fileAssociations" ];
      before = [ ];
      data = ''
        ${./scripts/startup-commands.sh}
      '';
    };
}
