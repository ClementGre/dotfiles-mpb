#!/bin/bash

if pgrep -x "Twingate" > /dev/null; then
  # Twingate is running
  :
else
    open -a Twingate
    sleep 0.5
fi

# Opening the app while it is already running opens the context menu.
sketchybar --set vpn popup.drawing=off
open -a Twingate
