#!/bin/bash

sketchybar --add item wifi right \
           --set wifi icon=􀙇 \
                      icon.color=0xffE96F42 \
                      label.drawing=off \
                      script="$PLUGIN_DIR/wifibluetooth.sh" \
                      update_freq=2 \
                      click_script="$BIN_DIR/menus -s com.apple.menuextra.wifi" \
           --add item bluetooth right \
           --set bluetooth icon=󰂱 \
                           icon.font="Hack Nerd Font:Bold:18.0" \
                           icon.color=0xff0081FB \
                           label.drawing=off \
                           click_script="$BIN_DIR/menus -s com.apple.menuextra.bluetooth"
