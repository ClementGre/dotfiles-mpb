#!/bin/bash

sketchybar --add item control right \
           --set control icon=􀜊 \
                         click_script="$BIN_DIR/menus -s com.apple.menuextra.controlcenter"
