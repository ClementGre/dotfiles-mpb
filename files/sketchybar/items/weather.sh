#!/bin/bash

sketchybar -m \
              --add item        weather_icon q \
              --set weather_icon icon.font="SF Pro:Medium:16" \
                                icon.drawing=on \
                                label.drawing=off \
                                icon.padding_left=0 \
                                icon.padding_right=6 \
                                update_freq=600 \
                                click_script="open -n '/System/Applications/Weather.app/'" \
              --add item        weather_label q \
              --set weather_label label.font="SF Pro:Bold:12" \
                                  icon.drawing=off \
                                  update_freq=600 \
                                  label.padding_right=4 \
                                  label.padding_left=9 \
                                  script="$PLUGIN_DIR/weather.sh" \
                                  click_script="open -n '/System/Applications/Weather.app/'"

# Subscribe to relevant events
sketchybar --subscribe weather_label system_woke
