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

  #[ -d "/Applications/Microsoft Excel.app" ] && \
  #  sudo $FILEICON set "/Applications/Microsoft Excel.app" "$DOTFILES/files/icns/apps/excel.icns"
  [ -d "/Applications/Microsoft Word.app" ] && \
    sudo $FILEICON set "/Applications/Microsoft Word.app" "$DOTFILES/files/icns/apps/word.icns"
  [ -d "/Applications/LibreOffice.app" ] && \
    sudo $FILEICON set "/Applications/LibreOffice.app" "$DOTFILES/files/icns/apps/libreoffice.icns"
  [ -d "/Applications/Sublime Text.app" ] && \
    sudo $FILEICON set "/Applications/Sublime Text.app" "$DOTFILES/files/icns/apps/sublime.icns"
  [ -d "/Applications/Spotify.app" ] && \
    sudo $FILEICON set "/Applications/Spotify.app" "$DOTFILES/files/icns/apps/spotify.icns"
  [ -d "/Applications/Beeper Desktop.app" ] && \
    sudo $FILEICON set "/Applications/Beeper Desktop.app" "$DOTFILES/files/icns/apps/beeper.icns"

else
  echo " -> fileicon not found, skipping icon setup"
fi


sudo rm /var/folders/*/*/*/com.apple.dock.iconcache
#sudo rm -r /var/folders/*/*/*/com.apple.iconservices*
sudo killall Dock
