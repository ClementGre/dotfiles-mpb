#!/bin/bash

# Shown while a Focus (Do Not Disturb, ...) is on, updated instantly by helpers/focus.swift.
# When no Focus is on: "dim" keeps it visible but faded, "hide" removes it.
# Works with the native Focus icon set to always show (it reads its dimming) or "Lorsque actif".
DND_OFF="${SKETCHYBAR_DND_OFF:-hide}"
DND_COLOR=0xff6564EA
DND_DIMMED_COLOR=0x8d6c6caf  # same color 50% desaturated (towards its grey), at 55% opacity

# Opens the native Focus menu, or Control Center if that icon is hidden while no Focus is on
sketchybar --add item disturb right \
           --set disturb icon=􀆺 \
                         icon.color=$DND_DIMMED_COLOR \
                         icon.padding_left=0 \
                         icon.padding_right=4 \
                         label.drawing=off \
                         click_script="$BIN_DIR/menus -s com.apple.menuextra.focusmode || $BIN_DIR/menus -s com.apple.menuextra.controlcenter"

pkill -f "$BIN_DIR/focus"
$BIN_DIR/focus disturb "$DND_OFF" "$DND_COLOR" "$DND_DIMMED_COLOR" &
