#!/bin/bash

# Menu bar icons that don't have their own item, in a popup (built on open by plugins/apps.sh)
sketchybar \
  --add item apps right \
  --set apps icon="􁇵" \
    label.drawing=off \
    click_script="$PLUGIN_DIR/popup_toggle.sh apps $PLUGIN_DIR/apps.sh" \
    script="sketchybar --set apps popup.drawing=off" \
    popup.background.drawing=on \
    popup.background.corner_radius=5 \
    popup.height=24 \
  --subscribe apps mouse.exited.global
