#!/bin/bash

sketchybar -m --add       item               network_up q                                               \
              --set       network_up         label.font="SF Pro:Semibold:9"                                   \
                                             icon.font="SF Pro:Heavy:7"                                    \
                                             icon=􀄨                                                         \
                                             icon.padding_right=0                                           \
                                             icon.highlight_color=0xff929598                               \
                                             y_offset=8                                                    \
                                             width=0                                                       \
                                             update_freq=2                                                 \
                                             script="$PLUGIN_DIR/network.sh"              \
                                             click_script="open -n '/Applications/Little Snitch Mini.app/'" \
                                                                                                           \
              --add       item               network_down q                                             \
              --set       network_down       label.font="SF Pro:Semibold:9"                                   \
                                             icon.font="SF Pro:Heavy:7"                                    \
                                             icon=􀄩                                                         \
                                             icon.padding_right=0                                           \
                                             icon.highlight_color=0xff929598                              \
                                             y_offset=-2 \
                                             click_script="open -n '/Applications/Little Snitch Mini.app/'" \
