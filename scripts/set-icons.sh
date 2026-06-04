#!/bin/zsh

DOTFILES="/Users/clement/GitHub/dotfiles-MBP"
FILEICON="/opt/homebrew/bin/fileicon"

echo " -> Setting custom icons..."

if [ -x "$FILEICON" ]; then
  [ -d "$HOME/GitHub" ] && \
    sudo $FILEICON set "$HOME/GitHub" "$DOTFILES/files/icns/folders/github.icns"
  [ -d "$HOME/Git" ] && \
    sudo $FILEICON set "$HOME/GitHub" "$DOTFILES/files/icns/folders/git.icns"

  [ -d "/Applications/Zen.app" ] && \
    sudo $FILEICON set "/Applications/Zen.app" "$DOTFILES/files/icns/apps/zen.icns"

  [ -d "/Applications/Claude.app" ] && \
    sudo $FILEICON set "/Applications/Claude.app" "$DOTFILES/files/icns/apps/claudec.icns"

  [ -d "/Applications/Termius.app" ] && \
    sudo $FILEICON set "/Applications/Termius.app" "$DOTFILES/files/icns/apps/termius.icns"

else
  echo " -> fileicon not found, skipping icon setup"
fi


sudo rm /var/folders/*/*/*/com.apple.dock.iconcache
sudo rm -r /var/folders/*/*/*/com.apple.iconservices*
sudo killall Dock
