# dotfiles-mbp

My nix-darwin dotfiles for my personal MacBook Pro.

# Useful commands
- restart sketchybar: `sketchybar --reload` or `launchctl stop org.nixos.sketchybar`
- if nix daemon is broken: `sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist`
- debug sketchybar locally: `cd ~/.config/ && sudo rm ./sketchybar && sudo ln -s ~/GitHub/dotfiles-MBP/files/sketchybar sketchybar`
