#!/bin/bash

sketchybar -m --add item        cpu_label q \
              --set cpu_label   label.font="SF Pro:Semibold:7" \
                                label=CPU \
                                y_offset=8 \
                                icon.drawing=off \
                                width=0 \
                                click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'" \
              --add item        cpu_percent_unit q \
              --set cpu_percent_unit label.font="SF Pro:Semibold:8.5" \
                                label=% \
                                y_offset=-2 \
                                icon.drawing=off \
                                label.padding_left=1 \
                                click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'" \
              --add item        cpu_percent q \
              --set cpu_percent label.font="SF Pro:Bold:10" \
                                y_offset=-2 \
                                icon.drawing=off \
                                label.padding_right=0 \
                                update_freq=2 \
                                script="$PLUGIN_DIR/cpu.sh" \
                                click_script="open -n '/System/Applications/Utilities/Activity Monitor.app/'"
