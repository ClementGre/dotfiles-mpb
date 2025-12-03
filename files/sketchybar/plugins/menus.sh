#!/bin/bash

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

MENU_LIST="$(./helpers/bin/menus -l)"


IFS=$'\n' read -rd '' -a MENUS <<<"$MENU_LIST"

BG_COLOR="0xff151A23"
CORNER_RADIUS=4

EXISTING_ITEMS=($(sketchybar --query bar | jq -r '.items[] | select(startswith("menu_"))'))

NEW_ITEMS=()
for i in "${!MENUS[@]}"; do
  if [ "$i" -ge 9 ]; then break; fi
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
#CMDS+="background.color=$BG_COLOR "
CMDS+="icon.drawing=off "
CMDS+="label.padding_left=4 "
CMDS+="label.padding_right=4 "
#CMDS+="background.padding_left=0 "
#CMDS+="background.padding_right=1 "
#CMDS+="background.height=20 "
#CMDS+="background.corner_radius=$CORNER_RADIUS "
CMDS+="click_script=\"./helpers/bin/menus -s 1\" "

# Other menus
for i in "${!MENUS[@]}"; do
  if [ "$i" -eq 0 ]; then continue; fi
  if [ "$i" -ge 9 ]; then break; fi
  idx=$((i+1))
  label="${MENUS[$i]:0:4}"
  item="menu_$i"
  found=false
  for exist in "${EXISTING_ITEMS[@]}"; do
    if [[ "$exist" == "$item" ]]; then
      found=true
      break
    fi
  done
  if $found; then
    # Only update label for existing items
    CMDS+="--set $item label=\"$label\" "
  else
    # Create new item with all options
    CMDS+="--add item $item left "
    CMDS+="--set $item label=\"$label\" "
    CMDS+="label.font=\"SF Pro:Medium:11.0\" "
    CMDS+="icon.drawing=off "
    CMDS+="label.padding_left=4 "
    CMDS+="label.padding_right=3 "
    CMDS+="y_offset=1 "
    #CMDS+="background.padding_left=1 "
    #CMDS+="background.padding_right=1 "
    #CMDS+="background.height=20 "
    #CMDS+="background.color=$BG_COLOR "
    #CMDS+="background.corner_radius=$CORNER_RADIUS "
    CMDS+="click_script=\"./helpers/bin/menus -s $idx\" "
  fi
done
echo -e "$CMDS" | xargs -L 1 sketchybar
