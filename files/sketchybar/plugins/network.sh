#!/usr/bin/env bash
UPDOWN=$(ifstat -i "en0" -b 0.1 1 | tail -n1)
DOWN=$(echo $UPDOWN | awk "{ print \$1 }" | cut -f1 -d ".")
UP=$(echo $UPDOWN | awk "{ print \$2 }" | cut -f1 -d ".")

# Determine units and format values
DOWN_UNIT="kbps"
DOWN_FORMAT=$DOWN
if [ "$DOWN" -gt "999" ]; then
  DOWN_UNIT="Mbps"
  DOWN_FORMAT=$(echo $DOWN | awk '{ printf "%.0f", $1 / 1000}')
fi

UP_UNIT="kbps"
UP_FORMAT=$UP
if [ "$UP" -gt "999" ]; then
  UP_UNIT="Mbps"
  UP_FORMAT=$(echo $UP | awk '{ printf "%.0f", $1 / 1000}')
fi

sketchybar -m --set network_down label="$DOWN_FORMAT" icon.highlight=$(if [ "$DOWN" -gt "0" ]; then echo "off"; else echo "on"; fi) \
                     --set network_down_unit label="$DOWN_UNIT" \
                     --set network_up label="$UP_FORMAT" icon.highlight=$(if [ "$UP" -gt "0" ]; then echo "off"; else echo "on"; fi) \
                     --set network_up_unit label="$UP_UNIT"
