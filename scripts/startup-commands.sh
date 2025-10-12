#!/bin/zsh

echo " -> Restarting sketchybar..."

brew services restart sketchybar

echo " -> Starting skhd..."

skhd --install-service
skhd --start-service
