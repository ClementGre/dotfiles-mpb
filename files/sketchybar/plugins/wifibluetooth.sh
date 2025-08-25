#!/usr/bin/env sh
FG1=0xffffffff
FG2=0xff929598

# From SF Symbols
NET_WIFI=􀙇
NET_OFF=􀙈

# Bluetooth Icons
BT_OFF=󰂲
BT_DISCONNECTED=󰂯
BT_CONNECTED_1=󰂱
BT_CONNECTED_2=󰂰
BT_CONNECTED_3=󰂳
BT_CONNECTED_4_PLUS=󰂴

# When switching between devices, it's possible to get hit with multiple
# concurrent events, some of which may occur before `scutil` picks up the
# changes, resulting in race conditions.
sleep 1

# Reusable awk functions for color calculation
AWK_FUNCTIONS=' \
  function hsb_to_rgb(h, s, v,   r, g, b, i, f, p, q, t_val) { \
      h /= 60; \
      i = int(h); \
      f = h - i; \
      p = v * (1 - s); \
      q = v * (1 - s * f); \
      t_val = v * (1 - s * (1 - f)); \
      if (i == 0) { r=v; g=t_val; b=p; } \
      else if (i == 1) { r=q; g=v; b=p; } \
      else if (i == 2) { r=p; g=v; b=t_val; } \
      else if (i == 3) { r=p; g=q; b=v; } \
      else if (i == 4) { r=t_val; g=p; b=v; } \
      else { r=v; g=p; b=q; } \
      printf "0xff%02x%02x%02x\n", r*255, g*255, b*255; \
  } \
  function max(a, b) { return a > b ? a : b } \
  function min(a, b) { return a < b ? a : b } \
'

# Get Wi-Fi status using wdutil
STATUS=$(sudo wdutil info)

# --- Wi-Fi Section ---
WIFI_DATA=$(echo "$STATUS" | sed -n '/^WIFI$/,/^BLUETOOTH$/p' | sed '$d')

WIFI_POWER_ON=$(echo "$WIFI_DATA" | grep -c "Power                : On")
SSID=$(echo "$WIFI_DATA" | awk -F': ' '/^    SSID                 :/ {print $2}')
RSSI=$(echo "$WIFI_DATA" | awk -F' ' '/^    RSSI                 :/ {print $3}')

WIFI_ICON=$NET_WIFI
WIFI_COLOR=$FG1

if [ "$WIFI_POWER_ON" -eq 0 ]; then
  WIFI_ICON=$NET_OFF
  WIFI_COLOR=$FG2
elif [ "$SSID" = "None" ]; then
  WIFI_COLOR=$FG2
else
  # Connected, check signal strength
  WIFI_COLOR=$(awk -v rssi="$RSSI" "
    $AWK_FUNCTIONS
    BEGIN {
      rssi_min = -90;
      rssi_max = -50;
      rssi_clamped = max(rssi_min, min(rssi_max, rssi));
      t = (rssi_clamped - rssi_min) / (rssi_max - rssi_min);
      hue = t * 120; # Green (120) to Red (0)
      saturation = 1.0;
      brightness = 0.9;
      hsb_to_rgb(hue, saturation, brightness);
    }
  ")
fi

# --- Bluetooth Section ---
BT_DATA=$(echo "$STATUS" | sed -n '/^BLUETOOTH$/,/^AWDL$/p' | sed '$d')
BT_POWER_ON=$(echo "$BT_DATA" | grep -c "Power                : On")
CONNECTED_COUNT=$(echo "$BT_DATA" | awk -F'connected=' '/Devices/ {print $2}' | sed 's/)//')

if [ "$BT_POWER_ON" -eq 0 ]; then
  BT_ICON=$BT_OFF
  BT_COLOR=$FG2
else
  if [ "$CONNECTED_COUNT" -gt 0 ]; then
    # Set icon based on device count
    case "$CONNECTED_COUNT" in
      1) BT_ICON=$BT_CONNECTED_1 ;;
      2) BT_ICON=$BT_CONNECTED_2 ;;
      3) BT_ICON=$BT_CONNECTED_3 ;;
      *) BT_ICON=$BT_CONNECTED_4_PLUS ;;
    esac
    BT_COLOR=0xff0082FC
  else
    BT_ICON=$BT_DISCONNECTED
    BT_COLOR=$FG2
  fi
fi

sketchybar --animate sin 5 --set wifi icon="$WIFI_ICON" icon.color="$WIFI_COLOR" \
                         --set bluetooth icon="$BT_ICON" icon.color="$BT_COLOR"
