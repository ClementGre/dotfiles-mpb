#!/bin/bash


sketchybar --add item volume-icon right \
           --set volume-icon \
                        label.drawing=off \
                        icon.padding_left=0 \
                        click_script="open -a 'Audio MIDI Setup'" \

sketchybar --add item volume right \
           --set volume script="$PLUGIN_DIR/volume.sh" \
                        icon.drawing=off \
                        label.font="SF Pro:Bold:12" \
                        label.padding_right=2 \
                        label.padding_left=8 \
                        click_script="open -a 'Audio MIDI Setup'" \
           --subscribe volume volume_change

