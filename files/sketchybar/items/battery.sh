#!/bin/sh

# AlDente Battery Icon example
#sketchybar --add item battery-icon2 right \
#           --set battery-icon2  \
#                              label.font="SF Pro:Heavy:10" \
#                              label="􂬺􀅽" \
#                              label.padding_right=10 \
#                              \
#                              icon.font="SF Pro:Light:20" \
#                              icon.drawing=on \
#                              icon.color=0xFFE08A07 \
#                              icon.width=4 \
#                              icon="􀛪" \
#                              click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'"
#
#
#sketchybar --add item battery-icon right \
#           --set battery-icon  \
#                              label.font="SF Pro:Heavy:10" \
#                              label="􂬺􀅼" \
#                              label.padding_right=10 \
#                              icon.font="SF Pro:Light:20" \
#                              icon.drawing=on \
#                              icon.color=0xFF00B000 \
#                              icon.width=4 \
#                              icon="􀛪" \
#                              click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'"
#
#sketchybar --add item battery-icon1 right \
#           --set battery-icon1  \
#                              label.font="SF Pro:Heavy:10" \
#                              label="􂬺􀊅" \
#                              label.padding_right=12 \
#                              \
#                              icon.font="SF Pro:Light:20" \
#                              icon.drawing=on \
#                              icon.color=0xFF0373FF \
#                              icon.width=5 \
#                              icon="􀛪" \
#                              click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'"
#
#
#sketchybar --add item battery-icon3 right \
#           --set battery-icon3  \
#                              label.font="SF Pro:Black:10" \
#                              label="􀅽" \
#                              label.padding_right=15 \
#                              \
#                              icon.font="SF Pro:Light:20" \
#                              icon.drawing=on \
#                              icon.color=0xFFE02020 \
#                              icon.width=10 \
#                              icon="􀛪" \
#                              click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'"

sketchybar --add item battery-icon right \
           --set battery-icon  \
                              icon.font="SF Pro:Light:20" \
                              icon.drawing=on \
                              icon="􀛪" \
                              label.padding_left=0 \
                              icon.padding_left=0 \
                              click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'"

sketchybar --add item battery-percent right \
           --set battery-percent update_freq=30 \
                         script="$PLUGIN_DIR/aldente.sh" \
                         icon.drawing=off \
                         label.font="SF Pro:Bold:12" \
                         label.padding_right=1 \
                         label.padding_left=8 \
                         click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'" \
           --subscribe battery-percent system_woke power_source_change


# No AlDente version
#sketchybar --add item battery right \
#           --set battery update_freq=120 \
#                         script="$PLUGIN_DIR/battery.sh" \
#                         click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'" \
#           --subscribe battery system_woke power_source_change

# Alias version
#sketchybar --add alias "AlDente,Item-0" right \
#           --set "AlDente,Item-0" alias.color=0xffffffff \
#                                  click_script="osascript -e 'tell application \"System Events\" to tell (value of attribute \"AXExtrasMenuBar\" of process \"AlDente\" ) to click first menu bar item'"

