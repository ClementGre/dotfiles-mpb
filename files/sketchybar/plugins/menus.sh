#!/bin/bash

MENU_LIST="$(./helpers/bin/menus -l)"
IFS=$'\n' read -rd '' -a MENUS <<<"$MENU_LIST"

BG_COLOR="0xff151A23"
CORNER_RADIUS=4

#for i in $(sketchybar --query bar | jq -r '.items[] | select(startswith("menu_"))'); do
#  sketchybar --remove "$i"
#done
#
#sketchybar --add item menu_0 left \
#  --set menu_0 label="${MENUS[0]}" \
#  label.font="SF Pro:SemiBold:13.0" \
#  background.color=$BG_COLOR \
#  icon.drawing=off \
#  label.padding_left=5 \
#  label.padding_right=5 \
#  background.padding_left=0 \
#  background.padding_right=1 \
#  background.height=20 \
#  background.corner_radius=$CORNER_RADIUS \
#  click_script="$BIN_DIR/menus -s 1"
#
#for i in "${!MENUS[@]}"; do
#  if [ "$i" -eq 0 ]; then continue; fi
#  idx=$((i+1))
#  label="${MENUS[$i]:0:1}"
#  sketchybar --add item menu_$i left \
#    --set menu_$i label="$label" \
#    label.font="SF Pro:Medium:11.0" \
#    icon.drawing=off \
#    label.padding_left=4 \
#    label.padding_right=5 \
#    background.padding_left=1 \
#    background.padding_right=1 \
#    background.height=20 \
#    background.color=$BG_COLOR \
#    background.corner_radius=$CORNER_RADIUS \
#    click_script="$BIN_DIR/menus -s $idx"
#done

EXISTING_ITEMS=($(sketchybar --query bar | jq -r '.items[] | select(startswith("menu_"))'))

NEW_ITEMS=()
for i in "${!MENUS[@]}"; do
  NEW_ITEMS+=("menu_$i")
done

TO_REMOVE=()
for item in "${EXISTING_ITEMS[@]}"; do
  skip=false
  for new in "${NEW_ITEMS[@]}"; do
    [[ "$item" == "$new" ]] && skip=true && break
  done
  $skip || TO_REMOVE+=("$item")
done

# Command buffer
CMDS=""
for item in "${TO_REMOVE[@]}"; do
  CMDS+="--remove $item\n"
done

# App menu
CMDS+="--add item menu_0 left "
CMDS+="--set menu_0 label=\"${MENUS[0]}\" "
CMDS+="label.font=\"SF Pro:SemiBold:13.0\" "
CMDS+="background.color=$BG_COLOR "
CMDS+="icon.drawing=off "
CMDS+="label.padding_left=5 "
CMDS+="label.padding_right=5 "
CMDS+="background.padding_left=0 "
CMDS+="background.padding_right=1 "
CMDS+="background.height=20 "
CMDS+="background.corner_radius=$CORNER_RADIUS "
CMDS+="click_script=\"./helpers/bin/menus -s 1\" "

# Other menus
for i in "${!MENUS[@]}"; do
  if [ "$i" -eq 0 ]; then continue; fi
  idx=$((i+1))
  label="${MENUS[$i]:0:4}"
  CMDS+="--add item menu_$i left "
  CMDS+="--set menu_$i label=\"$label\" "
  CMDS+="label.font=\"SF Pro:Medium:11.0\" "
  CMDS+="icon.drawing=off "
  CMDS+="label.padding_left=4 "
  CMDS+="label.padding_right=5 "
  CMDS+="background.padding_left=1 "
  CMDS+="background.padding_right=1 "
  CMDS+="background.height=20 "
  CMDS+="background.color=$BG_COLOR "
  CMDS+="background.corner_radius=$CORNER_RADIUS "
  CMDS+="click_script=\"./helpers/bin/menus -s $idx\" "
done
echo -e "$CMDS" | xargs -L 1 sketchybar
