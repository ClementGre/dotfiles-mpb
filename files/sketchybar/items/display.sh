#!/bin/sh
sketchybar --add item display right \
           --set display icon=􂇌 \
                         icon.font="SF Pro:Medium:13" \
                         label.drawing=off \
                         click_script="/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay toggle -appMenu"
                         #click_script="osascript -e 'tell application \"System Events\" to keystroke \"d\" using {control down}'"

#BetterDisplay,Item-0
