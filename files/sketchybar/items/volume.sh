#!/bin/bash


sketchybar --add item volume-icon right \
           --set volume-icon \
                        label.drawing=off \
                        icon.padding_left=0 \
                        click_script="$BIN_DIR/menus -s com.apple.menuextra.sound" \

sketchybar --add item volume right \
           --set volume script="$PLUGIN_DIR/volume.sh" \
                        icon.drawing=off \
                        label.font="SF Pro:Bold:12" \
                        label.padding_right=2 \
                        label.padding_left=8 \
                        click_script="$BIN_DIR/menus -p Vorssaint notch.activation notch.quickAccess.00000000-0000-4000-8000-000000000004 || $BIN_DIR/menus -s com.apple.menuextra.sound" \
           --subscribe volume volume_change
#                        click_script="open -a 'Audio MIDI Setup'" \
