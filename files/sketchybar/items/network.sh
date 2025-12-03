#!/bin/bash

sketchybar -m \
              --add       item               network_up_unit q                                             \
              --set       network_up_unit    label.font="SF Pro:Regular:8"                                 \
                                             label="ps"                                                   \
                                             icon.drawing=off                                             \
                                             y_offset=7                                                   \
                                             icon.drawing=off                                             \
                                             label.padding_left=2                                         \
                                             width=0                                                       \
                                             click_script="open -n '/Applications/Little Snitch Mini.app/'" \
              --add       item               network_down_unit q                                           \
              --set       network_down_unit  label.font="SF Pro:Regular:8"                                \
                                             label="ps"                                                   \
                                             icon.drawing=off                                             \
                                             y_offset=-3                                                  \
                                             icon.drawing=off                                             \
                                             label.padding_left=2                                         \
                                             click_script="open -n '/Applications/Little Snitch Mini.app/'" \
              --add       item               network_up q                                               \
              --set       network_up         label.font="SF Pro:Bold:10"                                    \
                                             icon.font="SF Pro:Heavy:8"                                    \
                                             icon=􀄨                                                         \
                                             icon.padding_right=0                                           \
                                             icon.highlight_color=0xff929598                               \
                                             label.padding_right=0                                          \
                                             y_offset=8                                                    \
                                             width=0                                                       \
                                             update_freq=2                                                 \
                                             script="$PLUGIN_DIR/network.sh"              \
                                             click_script="open -n '/Applications/Little Snitch Mini.app/'" \
              --add       item               network_down q                                             \
              --set       network_down       label.font="SF Pro:Bold:10"                                   \
                                             icon.font="SF Pro:Heavy:8"                                    \
                                             icon=􀄩                                                         \
                                             icon.padding_right=0                                           \
                                             icon.highlight_color=0xff929598                              \
                                             label.padding_right=0                                          \
                                             y_offset=-2 \
                                             click_script="open -n '/Applications/Little Snitch Mini.app/'" \
