#!/bin/bash

# Toggles an item's popup. While it is open, the next click anywhere else closes it:
# sketchybar only sends mouse.exited.global once the popup has been hovered.

ITEM="$1"
PREPARE="$2"  # optional script run in the background on opening, e.g. to refresh the popup

if [ "$(sketchybar --query "$ITEM" | jq -r '.popup.drawing')" = "on" ]; then
  sketchybar --set "$ITEM" popup.drawing=off
  exit 0
fi
# Watch for the next click right away, so none is missed while the popup opens
exec 3< <("$CONFIG_DIR/helpers/bin/wait_click")
sketchybar --set "$ITEM" popup.drawing=on
[ -n "$PREPARE" ] && "$PREPARE" &

read -r X Y <&3

# A click on the item itself runs this script again, which closes the popup
ON_ITEM=$(sketchybar --query "$ITEM" | jq --argjson x "$X" --argjson y "$Y" \
  '[.bounding_rects[] | select($x >= .origin[0] and $x <= .origin[0] + .size[0]
                           and $y >= .origin[1] and $y <= .origin[1] + .size[1])] | length > 0')
[ "$ON_ITEM" = "true" ] && exit 0

# Let a popup entry's own click handling run first
sleep 0.2
sketchybar --set "$ITEM" popup.drawing=off
