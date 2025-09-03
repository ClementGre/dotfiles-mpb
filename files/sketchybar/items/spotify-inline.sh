#!/bin/bash

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

spotify_cover=(
  script="$PLUGIN_DIR/spotify-inline.sh"
  click_script="open -a 'Spotify';"
  update_freq=30
  label.drawing=off
  icon.drawing=off
  padding_right=2
  y_offset=2
  background.image.scale=.035
  background.image.drawing=on
  background.drawing=on
  background.image.corner_radius=4
)

spotify_title=(
  icon.drawing=off
  padding_left=0
  padding_right=0
  width=0
  label.font="SF Pro:Bold:10"
  y_offset=9
  click_script="open -a 'Spotify';"
)

spotify_artist=(
  icon.drawing=off
  y_offset=-3
  padding_left=0
  padding_right=0
#  width=0
  label.font="SF Pro:Regular:9"
  click_script="open -a 'Spotify';"
)

sketchybar --add event spotify_change $SPOTIFY_EVENT \
           --add item spotify_cover e         \
           --set spotify_cover "${spotify_cover[@]}"             \
                                                                 \
           --add item spotify_title e         \
           --set spotify_title "${spotify_title[@]}"             \
                                                                 \
           --add item spotify_artist e        \
           --set spotify_artist "${spotify_artist[@]}"           \
           --subscribe spotify_cover spotify_change  \
