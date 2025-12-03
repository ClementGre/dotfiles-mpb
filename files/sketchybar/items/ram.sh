#!/bin/bash

sketchybar -m --add item ram_label q \
              --set ram_label label.font="SF Pro:Semibold:7" \
                               label=RAM \
                               y_offset=8 \
                               icon.drawing=off \
                               width=0 \
                               click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'" \
              --add item ram_percentage_unit q \
              --set ram_percentage_unit label.font="SF Pro:Semibold:7.5" \
                               label=Go \
                               y_offset=-3 \
                               icon.drawing=off \
                               label.padding_left=1 \
                               click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'" \
              --add item ram_percentage q \
              --set ram_percentage label.font="SF Pro:Bold:10" \
                                    y_offset=-2 \
                                    icon.drawing=off \
                                    label.padding_right=0 \
                                    update_freq=2 \
                                    script="~/.config/sketchybar/plugins/ram.sh" \
                                    click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'"
