#!/bin/bash

# Groups the apps, VPN and display items (sourced just before) in one pill, with smaller icons so
# the three stay narrower than before. The pill is orange at low opacity (the first byte of the
# colors: 0x2e = 18%), which reads as a subtle warm tint on the black bar.
# apps is the leftmost of the three, display the rightmost.
PILL_COLOR=0x2eff7a1a
PILL_BORDER=0x40ff7a1a
# The same colors composited over black, for the popups: they cover windows, so can't be transparent
POPUP_COLOR=0xff2e1605
POPUP_BORDER=0xff401f07

UTILITY_ICON=(
  icon.font="SF Pro:Semibold:11.5"
  icon.color=0xffffffff
  icon.padding_left=3
  icon.padding_right=3
  icon.y_offset=1
)

UTILITY_POPUP=(
  popup.background.color=$POPUP_COLOR
  popup.background.border_color=$POPUP_BORDER
  popup.background.border_width=1
)

sketchybar --set apps "${UTILITY_ICON[@]}" "${UTILITY_POPUP[@]}" icon.padding_left=3 \
           --set vpn "${UTILITY_ICON[@]}" "${UTILITY_POPUP[@]}" \
           --set display "${UTILITY_ICON[@]}" icon.padding_right=6 \
           --add bracket utilities apps vpn display \
           --set utilities background.drawing=on \
                           background.color=$PILL_COLOR \
                           background.border_color=$PILL_BORDER \
                           background.border_width=1 \
                           background.corner_radius=6 \
                           background.height=22 \
                           background.y_offset=0
