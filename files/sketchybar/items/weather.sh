#!/bin/bash

# Icon and temperature are set by a resident helper (helpers/weather.swift), restarted on reload.
# Opened as an app so macOS can ask it for location access, errors in ~/Library/Logs
sketchybar -m \
              --add item        weather_icon q \
              --set weather_icon icon.font="SF Pro:Medium:16" \
                                icon.drawing=on \
                                label.drawing=off \
                                icon.padding_left=0 \
                                icon.padding_right=6 \
                                click_script="open -n '/System/Applications/Weather.app/'" \
              --add item        weather_label q \
              --set weather_label label.font="SF Pro:Bold:12" \
                                  icon.drawing=off \
                                  label.padding_right=4 \
                                  label.padding_left=9 \
                                  click_script="open -n '/System/Applications/Weather.app/'"

pkill -f "/weather.app/Contents/MacOS/weather"  # open resolves ~/.config symlinks
open -g -n "$BIN_DIR/weather.app" --stderr "$HOME/Library/Logs/sketchybar-weather.log" \
  --args weather_icon weather_label
