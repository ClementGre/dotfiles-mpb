#!/bin/bash

sketchybar --add item disturb right \
           --set disturb icon=􀆺 \
                         icon.color=0xff6564EA \
                         label.drawing=off \
                         drawing=off \
                         script="$PLUGIN_DIR/disturb.sh" \
                         click_script="$BIN_DIR/menus -s com.apple.menuextra.focusmode" \
                         update_freq=1
