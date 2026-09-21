#!/bin/bash

# Fills the "apps" popup with the menu bar icons that aren't already in the bar.
# Run by popup_toggle.sh in the background each time the popup opens: it shows last time's rows
# right away, and this updates them in place.

# Apps that already have their own item in the bar
HIDDEN=("AlDente" "BetterDisplay" "Tailscale" "Twingate" "FineTune")

# Per-app settings, by app name (second column of `menus -e`):
#   "<app name>|<action>|<always>|<label>"
#   action: empty or "menu" = open its menu bar menu, "open" = open -a the app,
#           anything else = a shell command
#   always: "always" to list it even when it isn't running (it's then launched with open -a)
#   label:  shown instead of the app name
APPS=(
  "Cryptomator|open||"
  "TextInputMenuAgent|menu||Clavier"
)

ICON_SCALE=0.6
MENUS="$CONFIG_DIR/helpers/bin/menus"

settings_for() {
  local entry
  for entry in "${APPS[@]}"; do
    [ "${entry%%|*}" = "$1" ] && echo "$entry" && return
  done
}

is_hidden() {
  local app
  for app in "${HIDDEN[@]}"; do
    [ "$app" = "$1" ] && return 0
  done
  return 1
}

bundle_id_of() {
  local dir
  for dir in /Applications /Applications/Utilities /System/Applications "$HOME/Applications"; do
    if [ -d "$dir/$1.app" ]; then
      /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$dir/$1.app/Contents/Info.plist" 2>/dev/null
      return
    fi
  done
}

# "<app name>|<menus -s target, empty when not running>|<bundle id>"
ENTRIES=()
SEEN="|"
while IFS=$'\t' read -r target app bundle _; do
  if [ "$app" = "Apple" ] || [ "$app" = "-" ] || is_hidden "$app"; then continue; fi
  case "$SEEN" in *"|$app|"*) continue ;; esac  # only an app's first icon can be opened
  SEEN="$SEEN$app|"
  ENTRIES+=("$app|$target|$bundle")
done < <("$MENUS" -e)

for entry in "${APPS[@]}"; do
  IFS='|' read -r app action always label <<< "$entry"
  [ "$always" = "always" ] || continue
  case "$SEEN" in *"|$app|"*) continue ;; esac
  SEEN="$SEEN$app|"
  ENTRIES+=("$app||$(bundle_id_of "$app")")
done

IFS=$'\n' ENTRIES=($(printf '%s\n' "${ENTRIES[@]}" | sort -f))
unset IFS

EXISTING=" $(sketchybar --query apps | jq -r '.popup.items[]?' | tr '\n' ' ') "

# Existing rows are updated in place (no clearing, so the popup stays filled while refreshing)
row() {
  local name="apps.entry.$1"
  shift
  case "$EXISTING" in
    *" $name "*) ARGS+=(--set "$name" "$@") ;;
    *) ARGS+=(--add item "$name" popup.apps --set "$name" "$@") ;;
  esac
}

ARGS=()
i=0
for entry in "${ENTRIES[@]}"; do
  IFS='|' read -r app target bundle <<< "$entry"
  IFS='|' read -r _ action always label <<< "$(settings_for "$app")"

  if [ -z "$target" ] || [ "$action" = "open" ]; then
    command="open -a '$app'"
  elif [ -z "$action" ] || [ "$action" = "menu" ]; then
    command="'$MENUS' -s '$target'"
  else
    command="$action"
  fi

  PROPS=(label="${label:-$app}"
         label.font="SF Pro:Medium:12.5"
         label.padding_left=6
         label.padding_right=10
         icon.drawing=on
         icon.width=32
         click_script="sketchybar --set apps popup.drawing=off; $command")
  if [ -n "$bundle" ] && [ "$bundle" != "-" ]; then
    PROPS+=(icon.background.drawing=on
            icon.background.image="app.$bundle"
            icon.background.image.scale=$ICON_SCALE
            icon.background.image.padding_left=8)  # the image ignores icon.padding_left
  else
    PROPS+=(icon.background.drawing=off)
  fi
  row "$i" "${PROPS[@]}"
  i=$((i + 1))
done

if [ "$i" -eq 0 ]; then
  row 0 label="Aucune app" icon.drawing=off click_script=""
  i=1
fi

# Rows left over from a longer list
for name in $EXISTING; do
  case "$name" in apps.entry.*) [ "${name#apps.entry.}" -ge "$i" ] && ARGS+=(--remove "$name") ;; esac
done

sketchybar "${ARGS[@]}"
