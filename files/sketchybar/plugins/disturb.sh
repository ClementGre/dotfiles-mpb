#!/usr/bin/env sh

ENABLED=$(defaults read com.apple.controlcenter "NSStatusItem Visible FocusModes")

if [ "$ENABLED" -eq 1 ]; then
  sketchybar --set "$NAME" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
