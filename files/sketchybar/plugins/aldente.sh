#!/bin/sh

# Wait for AlDente to update its state
sleep 0

STATS="$(shortcuts run "AlDenteStats")"
echo $STATS
# Split by ; : state;temp;percentage
IFS=';' read -r STATE TEMP PERCENTAGE <<< "$STATS"
# AlDente State is bugged and can only be used to differentiate between charging and sailing.
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$CHARGING" != "" ]; then # Plugged in
  if [ "$STATE" = "Charging" ]; then
    # Charging
    sketchybar --set "battery-icon" \
          label.font="SF Pro:Heavy:10" \
          label="􂬺􀅼" \
          label.padding_right=12 \
          icon.color=0xFF00B000 \
          icon.width=4
  elif [ "$STATE" = "Topup" ]; then
    # Charging
    sketchybar --set "battery-icon" \
          label.font="SF Pro:Heavy:10" \
          label="􂬺􀅃" \
          label.padding_right=12 \
          icon.color=0xFF00B000 \
          icon.width=4
  elif [ "$STATE" = "Sailing" ]; then
    # Sailing
    sketchybar --set "battery-icon" \
          label.font="SF Pro:Heavy:10" \
          label="􂬺􀊅" \
          label.padding_right=14 \
          icon.color=0xFF0373FF \
          icon.width=5
  elif [ "$STATE" = "Calibration" ]; then
    # Calibration
    sketchybar --set "battery-icon" \
              label.font="SF Pro:Heavy:10" \
              label="􂬺􀯛" \
              label.padding_right=12 \
              icon.color=0xFFFF0ECF \
              icon.width=4
  else
    # Uncharging
    sketchybar --set "battery-icon" \
              label.font="SF Pro:Heavy:10" \
              label="􂬺􀅽" \
              label.padding_right=12 \
              icon.color=0xFFE08A07 \
              icon.width=4
  fi
else # Unplugged
  if [ "$STATE" = "Calibration" ]; then
      # Calibration
      sketchybar --set "battery-icon" \
                label.font="SF Pro:Heavy:10" \
                label="􀅽􀯛" \
                label.padding_right=12 \
                icon.color=0xFFFF0ECF \
                icon.width=4
  else
    # Uncharging
    sketchybar --set "battery-icon" \
        label.font="SF Pro:Black:10" \
        label="􀅽" \
        label.padding_right=17 \
        icon.color=0xFFE02020 \
        icon.width=10
    fi
fi

sketchybar --set "battery-percent" label="${PERCENTAGE}%"


