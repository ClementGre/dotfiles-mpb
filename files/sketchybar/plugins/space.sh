#!/bin/bash

# Apply styling based on selection state
if [ "$SELECTED" = true ]; then
    sketchybar --set "$NAME" \
                        background.color=0xff431700 \
                        background.border_color=0xffcfcfcf

    # Extract space number from name (e.g., "space.1" -> "1")
    SPACE_NUM=$(echo "$NAME" | sed 's/space\.//')
    window_count=0
    window_count=$(osascript -e '
    tell application "System Events"
        set window_count to 0

        -- Get all visible processes that might have windows
        set visible_processes to (name of processes whose visible is true)

        repeat with process_name in visible_processes
            try
                tell process process_name
                    set proc_windows to count of windows
                    set window_count to window_count + proc_windows
                end tell
            end try
        end repeat

        return window_count
    end tell
    ')

    # Generate dots based on window count (max 4 dots)
    if [ "$window_count" -gt 0 ]; then
        # Show up to 4 dots, capped at 4
        padding_left="2"
        if [ "$window_count" -lt 5 ]; then
            display_count="$window_count"
            icon_color="0xffffffff"
            if [ "$window_count" -eq 1 ]; then
              padding_left="8"
            elif [ "$window_count" -eq 2 ]; then
              padding_left="6"
            elif [ "$window_count" -eq 3 ]; then
              padding_left="4"
            fi

        else
            display_count=4
            if [ "$window_count" -le 6 ]; then # 5-6 windows - green
                icon_color="0xff00ff00"
            else # 7+ windows - red
                icon_color="0xffff6060"
            fi
        fi
        dots=$(printf '·%.0s' $(seq 1 $display_count))

        sketchybar --set "$NAME" icon="$dots" icon.color="$icon_color" icon.padding_left="$padding_left"
    else
        dots=""
        sketchybar --set "$NAME" icon="$dots" icon.color="0xffffffff" icon.padding_left="1"
    fi
else
    sketchybar --set "$NAME" \
                        background.color=0x00ffffff \
                        background.border_color=0xff8f8f8f
fi
