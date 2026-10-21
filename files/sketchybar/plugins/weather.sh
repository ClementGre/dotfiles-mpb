#!/bin/bash
# Locked means nobody is looking: asleep, or a maintenance wake at night, where location services
# are often unavailable and the shortcut fails with a notification. Refreshed again on unlock
if ioreg -n Root -d1 | grep -q '"CGSSessionScreenIsLocked"=Yes'; then
  exit 0
fi

# Wait for the network and location services to be available
if [ "$SENDER" = "system_woke" ] || [ "$SENDER" = "screen_unlocked" ]; then
  sleep 10
fi

# Get weather stats from the shortcut
WEATHER_DATA="$(shortcuts run "WeatherStats" 2>/dev/null | sed 's/, /!/g')"

# Split by ", " delimiter
IFS='!' read -r NONE CONDITION TEMPERATURE <<< "$WEATHER_DATA"

# No location (or no network): keep the last weather shown and retry in 2 minutes instead of 10
if [ -z "$TEMPERATURE" ]; then
  exit 0
fi

# Switch/case for weather conditions and corresponding icons
case "$CONDITION" in
  "Ensoleillé"|"Clair"|"Temps clair")
    ICON="☀️"
    ;;
  "Nuageux")
    ICON="☁️"
    ;;
  "Pluie"|"Averses"|"Bruine")
    ICON="🌧️"
    ;;
  "Orageux"|"Orages")
    ICON="⛈️"
    ;;
  "Neige"|"Snowy"|"Neige")
    ICON="❄️"
    ;;
  "Brouillard"|"Foggy"|"Fog")
    ICON="🌫️"
    ;;
  "Venteux"|"Windy")
    ICON="💨"
    ;;
  "Nuages prédominants"|"Belles éclaircies"|"Partiellement nuageux"|"Ciel plutôt dégagé")
    ICON="🌤️"
    ;;
  *)
    ICON=$CONDITION
    ;;
esac

# Update the weather icon and label
sketchybar --set "weather_icon" icon="$ICON"
sketchybar --set "weather_label" label="$TEMPERATURE" update_freq=600
