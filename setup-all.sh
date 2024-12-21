#!/bin/zsh

echo "✨ Installing and configuring everything on this mac..."

# Mkdir directroy ~/Code
echo "> Creating tree..."
mkdir -p ~/Code

CMD_DIR=$(pwd)

# Installing Strap
echo "> Using Strap to setup this mac..."
git clone --depth 1 https://github.com/MikeMcQuaid/strap ~/Downloads/strap
cd ~/Downloads/strap || exit
bash strap.sh

# Add home-brew to path

# Installing Brewfile
echo "> Installing Software from the Brewfile..."
cd ~/Downloads/ || exit
brew bundle --file=~/Code/dotfiles/Brewfile

# Installing App Store Apps
echo "> Installing App Store Apps..."
mas install 1276493162 # reMarkable Desktop
mas install 1289583905 # Pixelmator Pro
mas install 1548711022 # Barbee - Hide Menu Bar Items
mas install 1287239339 # ColorSlurp
mas install 1355679052 # Dropover - Easier Drag & Drop
mas install 1085114709 # Parallels Desktop
mas install 1043565969 # Screen Bandit
mas install 570549457  # Spotica Menu
mas install 6443470555 # Vivid - Double your brightness
mas install 1502839586 # Hand Mirror
mas install 1629008763 # Little Snitch Mini
mas install 937984704  # Amphetamine

# Setting up files associations
echo "> Setting up file associations..."
cd "$CMD_DIR" || exit
sudo chmod +x ./file-associations.sh
./file-associations.sh
