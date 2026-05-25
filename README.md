# dotfiles-mbp

My nix-darwin dotfiles for my personal MacBook Pro.

## Useful commands

### Rebuild
```bash
sudo darwin-rebuild switch --impure --flake ~/GitHub/dotfiles-MBP/
```

### Update
```bash
nix flake update
```

### Reload Nix daemon
```bash
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
```

### Clean Nix Store
```bash
nix-store --gc
```

### Sketchybar
#### Restart:
```bash
sketchybar --reload
```
#### Restart with launchctl:
```bash
launchctl stop org.nixos.sketchybar
```
#### Debug locally:
```bash
cd ~/.config/ && sudo rm ./sketchybar && sudo ln -s ~/GitHub/dotfiles-MBP/files/sketchybar sketchybar
```
