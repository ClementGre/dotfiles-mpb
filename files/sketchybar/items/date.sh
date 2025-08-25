#!/bin/bash

sketchybar --add item time2 right \
           --set time2 width=55 align=left \
                       click_script="open -a 'BusyCal'"

sketchybar --add item time1 right \
           --set time1 padding_right=-16.5 \
                       padding_left=-15 \
                       click_script="open -a 'BusyCal'"

$BIN_DIR/clock &