#!/bin/sh

calendar_title=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  width=0
  label.font="SF Pro:Bold:10"
  y_offset=9
  click_script="open -a 'BusyCal'"
  script="$PLUGIN_DIR/calendar.sh"
  update_freq=30
)

calendar_time=(
  icon.drawing=off
  y_offset=-3
  padding_left=0
  padding_right=0
  width=0
  label.font="SF Pro:Regular:9"
  click_script="open -a 'BusyCal'"
)

sketchybar \
  --add item calendar_title right \
  --set calendar_title "${calendar_title[@]}" \
  --add item calendar_time right \
  --set calendar_time "${calendar_time[@]}"

