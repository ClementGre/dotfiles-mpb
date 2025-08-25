#!/bin/bash

sketchybar -m --add item ram_label q \
              --set ram_label label.font="SF Pro:Semibold:7" \
                               label=RAM \
                               y_offset=8 \
                               icon.drawing=off \
                               width=0 \
                               click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'" \
              --add item ram_percentage q \
              --set ram_percentage label.font="SF Pro:Bold:10" \
                                    y_offset=-2 \
                                    icon.drawing=off \
                                    update_freq=2 \
                                    script="~/.config/sketchybar/plugins/ram.sh" \
                                    click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'"
