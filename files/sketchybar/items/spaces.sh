#!/bin/bash

SPACE_SIDS=(4 3 2 1)
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

for sid in "${SPACE_SIDS[@]}"
do
  KEYCODE=$((17 + $sid))
  click_script="osascript -e 'tell application \"System Events\" to key code $KEYCODE using control down'"
  sketchybar --add space space.$sid q                                \
             --set space.$sid space=$sid                                 \
                              icon.font="SF Pro:Black:10.5"        \
                              icon="" \
                              icon.width=0                          \
                              icon.y_offset=-4                       \
                              icon.color=0xffffffff                    \
                              icon.padding_left=2 \
                              label.font="SF Pro:SemiBold:11" \
                              label=$sid                              \
                              label.y_offset=2                          \
                              label.width=21                           \
                              label.align=center \
                              background.border_color=0xff8f8f8f          \
                              background.color=0x00ffffff          \
                              background.border_width=1            \
                              background.height=19                 \
                              background.padding_right=1                 \
                              background.padding_left=1                 \
                              background.corner_radius=2          \
                              script="$PLUGIN_DIR/space.sh" \
                              click_script="$click_script" \
              --subscribe space.$sid front_app_switched

done
