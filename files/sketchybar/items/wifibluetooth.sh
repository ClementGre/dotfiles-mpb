#!/bin/bash

# Icons and colors (Wi-Fi by signal strength) are set by a resident helper
# (helpers/wifibluetooth.swift), restarted on reload
sketchybar --add item wifi right \
           --set wifi icon=􀙇 \
                      icon.color=0xffE96F42 \
                      label.drawing=off \
                      click_script="$BIN_DIR/menus -s com.apple.menuextra.wifi" \
           --add item bluetooth right \
           --set bluetooth icon=󰂱 \
                           icon.font="Hack Nerd Font:Bold:18.0" \
                           icon.color=0xff0081FB \
                           label.drawing=off \
                           click_script="$BIN_DIR/menus -s com.apple.menuextra.bluetooth"

pkill -f "$BIN_DIR/wifibluetooth"
$BIN_DIR/wifibluetooth wifi bluetooth &
