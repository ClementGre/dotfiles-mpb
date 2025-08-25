#!/bin/bash

COVER_PATH="/tmp/spotify_cover.jpg"
LAST_COVER_URL_PATH="/tmp/spotify_last_cover_url.txt"
MAX_LABEL_LENGTH=25

next () {
  osascript -e 'tell application "Spotify" to play next track'
  update
}
back () {
  osascript -e 'tell application "Spotify" to play previous track'
  update
}
play () {
  osascript -e 'tell application "Spotify" to playpause'
  update
}

repeat_toggle () {
  REPEAT=$(osascript -e 'tell application "Spotify" to get repeating')
  if [ "$REPEAT" = "false" ]; then
    sketchybar -m --set spotify.repeat icon.highlight=on
    osascript -e 'tell application "Spotify" to set repeating to true'
  else
    sketchybar -m --set spotify.repeat icon.highlight=off
    osascript -e 'tell application "Spotify" to set repeating to false'
  fi
}
shuffle_toggle () {
  SHUFFLE=$(osascript -e 'tell application "Spotify" to get shuffling')
  if [ "$SHUFFLE" = "false" ]; then
    sketchybar -m --set spotify.shuffle icon.highlight=on
    osascript -e 'tell application "Spotify" to set shuffling to true'
  else
    sketchybar -m --set spotify.shuffle icon.highlight=off
    osascript -e 'tell application "Spotify" to set shuffling to false'
  fi
}

scrubbing() {
  local duration_ms duration target
  duration_ms=$(osascript -e 'tell application "Spotify" to get duration of current track')
  duration=$((duration_ms / 1000))
  target=$((duration * PERCENTAGE / 100))

  osascript -e "tell application \"Spotify\" to set player position to $target"
  sketchybar -m --set spotify.state slider.percentage=$PERCENTAGE
}

truncate_text() {
  local text="$1"
  local max_length=${2:-$MAX_LABEL_LENGTH}
  if [ ${#text} -le "$max_length" ]; then
    echo "$text"
  else
    echo "${text:0:max_length}" | sed -E 's/\s+[[:alnum:]]*$//' | awk '{$1=$1};1' | sed 's/$/.../'
  fi
}

is_spotify_running() {
  # Returns 0 if Spotify is running, 1 otherwise
  pgrep -x "Spotify" > /dev/null 2>&1
}


update() {
  if ! is_spotify_running; then
    sketchybar -m --set spotify_cover drawing=off \
                  --set spotify_title drawing=off \
                  --set spotify_artist drawing=off
    return 0
  fi

  local state
  state=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)

  if [ "$state" != "playing" ]; then
    sketchybar -m --set spotify_cover drawing=off  \
                  --set spotify_title drawing=off  \
                  --set spotify_artist drawing=off
    exit 0
  fi
  # Set play or pause icon depending on state
  local play_icon=""
  if [ "$SPOTIFY_DISPLAY_CONTROLS" = "true" ]; then
    if [ "$state" = "playing" ]; then
      play_icon="􀊆"  # pause icon
    else
      play_icon="􀊄"  # play icon
    fi
  fi

  local track artist cover_url
  track=$(osascript -e 'tell application "Spotify" to get name of current track')
  artist=$(osascript -e 'tell application "Spotify" to get artist of current track')
  cover_url=$(osascript -e 'tell application "Spotify" to get artwork url of current track')

  # Check if cover URL has changed
  if [ ! -f "$LAST_COVER_URL_PATH" ] || [ "$(cat "$LAST_COVER_URL_PATH")" != "$cover_url" ]; then
    echo "$cover_url" > "$LAST_COVER_URL_PATH"
    if ! curl -s --max-time 2 "$cover_url" -o "$COVER_PATH"; then
      COVER_PATH=""
    fi
  fi

  track=$(truncate_text "$track" $((MAX_LABEL_LENGTH * 7/10)))
  artist=$(truncate_text "$artist")

  sketchybar -m \
    --set spotify_cover background.image="$COVER_PATH" background.color=0x00000000 drawing=on \
    --set spotify_title label="$track" drawing=on \
    --set spotify_artist label="$artist" drawing=on
}

scroll() {
  local duration_ms position time duration
  duration_ms=$(osascript -e 'tell application "Spotify" to get duration of current track')
  duration=$((duration_ms / 1000))
  position=$(osascript -e 'tell application "Spotify" to get player position')
  time=${position%.*}

  sketchybar -m --animate linear 10 \
    --set spotify.state slider.percentage=$((time * 100 / duration)) \
                         icon="$(date -r $time +'%M:%S')" \
                         label="$(date -r $duration +'%M:%S')"
}

update
