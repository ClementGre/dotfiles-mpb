#!/bin/bash

bash "$CONFIG_DIR/scripts/vpn_insa_is_on.sh"
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
    sketchybar --set vpn_insa \
                        icon.color=0xff2BE72B \
                        click_script="$CONFIG_DIR/scripts/vpn_insa_off.sh"
else
    sketchybar --set vpn_insa \
        icon.color=0xffEF2D2D \
        click_script="$CONFIG_DIR/scripts/vpn_insa_on.sh"
fi
