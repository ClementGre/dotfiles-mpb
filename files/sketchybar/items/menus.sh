#!/bin/bash

sketchybar --add item menus_trigger left \
           --set menus_trigger width=0 icon.drawing=off label.drawing=off script="$PLUGIN_DIR/menus.sh" \
           --subscribe menus_trigger front_app_switched
