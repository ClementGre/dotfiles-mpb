#!/bin/bash

sketchybar --add item apple left \
           --set apple width=32 \
           			   padding_left=5 \
           			   padding_right=0 \
           			   icon.drawing=off \
           			   label.drawing=off \
           			   background.drawing=on \
                   background.image="$RES_DIR/apple-rainbow.png" \
           			   background.image.drawing=on \
           			   background.image.scale=.5 \
           			   click_script="$BIN_DIR/menus -s 0"
