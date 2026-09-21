flake := justfile_directory()

# List recipes
default:
    @just --list

# Rebuild: installs/removes brew packages to match the Brewfile, no upgrades
switch:
    sudo darwin-rebuild switch --impure --flake {{flake}}

# Rebuild with brew update + upgrade, then re-apply custom icons (upgrades reset them)
upgrade:
    sudo DOTFILES_BREW_UPGRADE=1 darwin-rebuild switch --impure --flake {{flake}}
    just icons

# Update flake inputs (nixpkgs, pinned brew taps, ...), then upgrade
update:
    nix flake update --flake {{flake}}
    just upgrade

# Set custom folder and app icons
icons:
    {{flake}}/scripts/set-icons.sh

# Set default apps for file extensions
assoc:
    {{flake}}/scripts/file-associations.sh

# Rebuild sketchybar helpers and reload it
bar:
    make -C {{flake}}/files/sketchybar/helpers
    sketchybar --reload

# Delete unused nix store paths
gc:
    sudo nix-store --gc

# Reload the nix daemon
daemon:
    sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
