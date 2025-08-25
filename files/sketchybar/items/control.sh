#!/bin/bash

sketchybar --add item control right \
           --set control icon=􀜊 \
                         click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"ControlCenter\" ) to click menu bar item 2'"
