#!/bin/bash
# Wait for system to wake up and localization services to be available
if [ "$SENDER" = "system_woke" ]; then
  sleep 10
fi

# Get weather stats from the shortcut
WEATHER_DATA="$(shortcuts run "WeatherStats" | sed 's/, /!/g')"

# Split by ", " delimiter
IFS='!' read -r NONE CONDITION TEMPERATURE <<< "$WEATHER_DATA"

# Switch/case for weather conditions and corresponding icons
case "$CONDITION" in
  "Ensoleillé"|" Clair"|"Sunny")
    ICON="☀️"
    ;;
  "Nuageux"|"Cloudy"|"Partly Cloudy")
    ICON="☁️"
    ;;
  "Pluvieux"|"Rainy"|"Averses"|"Showers")
    ICON="🌧️"
    ;;
  "Orageux"|"Stormy"|"Orages"|"Thunderstorms")
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
  "Nuages prédominants"|"Partiellement nuageux")
    ICON="🌤️"
    ;;
  *)
    ICON=$CONDITION
    ;;
esac

# Update the weather icon and label
sketchybar --set "weather_icon" icon="$ICON"
sketchybar --set "weather_label" label="$TEMPERATURE"
