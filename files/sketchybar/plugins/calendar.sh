#!/bin/sh

MAX_TITLE_LENGTH=20

# Get current epoch time in seconds
current_epoch=$(date +%s)
current_epoch_minutes=$((current_epoch / 60))  # Convert to minutes

format_time_delta() {
    local seconds=$1

    # Absolute value for relative display
    local abs_seconds=${seconds#-}

    # If delta > 6 hours, show exact time with day label
    local hours=$((abs_seconds / 3600))
    if (( hours > 6 )); then
        # Determine target epoch from direction (future if seconds >= 0, past if < 0)
        local target_epoch
        if (( seconds >= 0 )); then
            target_epoch=$((current_epoch + abs_seconds))
        else
            target_epoch=$((current_epoch - abs_seconds))
        fi

        # Day labels (macOS BSD date supports -v for date arithmetic)
        local target_date today tomorrow day_after
        target_date=$(date -r "$target_epoch" +%Y-%m-%d)
        today=$(date +%Y-%m-%d)
        tomorrow=$(date -v+1d +%Y-%m-%d)
        day_after=$(date -v+2d +%Y-%m-%d)

        local day_label
        if [ "$target_date" = "$today" ]; then
            day_label="aujourd’hui"
        elif [ "$target_date" = "$tomorrow" ]; then
            day_label="demain"
        elif [ "$target_date" = "$day_after" ]; then
            day_label="après-demain"
        else
            # Fallback to explicit date
            day_label="le $(date -r "$target_epoch" +%d/%m)"
        fi

        local clock_time
        clock_time=$(date -r "$target_epoch" +%H:%M)
        if [ "$clock_time" = "00:00" ]; then
          echo "$day_label"
        else
          echo "$day_label à $clock_time"
        fi
        return
    fi

    # Relative display in h:mm (zero-padded minutes)
    local rel_hours=$((abs_seconds / 3600))
    local rel_minutes=$(((abs_seconds % 3600) / 60))
    printf "dans %dh %02dmin\n" "$rel_hours" "$rel_minutes"
}

get_calendar_color() {
    local calendar=$1
    case "$calendar" in
        "INSA")
            echo "0xFFFFCC99"  # Light engineering orange
            ;;
        "Personnel")
            echo "0xFF99CCFF"  # Light blue
            ;;
        "SIA")
            echo "0xFFCC99FF"  # Light purple
            ;;
        Cal*)
            echo "0xFFFF9D99"  # Light red
            ;;
        *)
            echo "0xFFFFFFFF"  # Default: white
            ;;
    esac
}

truncate_title() {
    local title=$1
    if [ ${#title} -gt $MAX_TITLE_LENGTH ]; then
        echo "${title:0:$((MAX_TITLE_LENGTH - 3))}..."
    else
        echo "$title"
    fi
}

# Fetch calendar events using icalBuddy
events=$(icalBuddy -n -li 4 -nrd -df "%Y-%m-%d" -tf "%H:%M:%S" -iep title,datetime -ec Routine,"ADE Direct" eventsToday+1)
nb_events=$(echo "$events" | grep -c '^• ')

# Function to parse a date/time string into epoch seconds
# Supports formats:
# - "YYYY-MM-DD" (all-day event)
# - "YYYY-MM-DD at HH:MM:SS" (timed event)
# - "HH:MM:SS" (time-only, assumes reference_date if provided, else today)
parse_date_to_epoch() {
    local date_str=$1
    local reference_date=$2  # Optional: reference date for time-only strings
    local epoch_time

    # Try parsing as "YYYY-MM-DD at HH:MM:SS"
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ at\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        epoch_time=$(date -j -f "%Y-%m-%d at %H:%M:%S" "$date_str" +%s)
    # Try parsing as "YYYY-MM-DD" (all-day event, time = 00:00:00)
    elif [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        epoch_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "${date_str} 00:00:00" +%s)
    # Try parsing as "HH:MM:SS" (time-only)
    elif [[ "$date_str" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        local use_date
        # Use reference_date if provided, else use today's date
        if [[ -n "$reference_date" ]]; then
            use_date="$reference_date"
        else
            use_date=$(date +%Y-%m-%d)
        fi
        epoch_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "${use_date} ${date_str}" +%s)
    else
        echo "Error: Unrecognized date format: '$date_str'" >&2
        return 1
    fi

    echo "$epoch_time"
}

# If no events, clear labels and exit
if [ "$nb_events" -eq 0 ]; then
    sketchybar --set calendar_title label="" \
               --set calendar_time label=""
    exit 0
fi

# Split events into lines and process each event
while IFS= read -r line; do
    # Skip empty lines or lines without a bullet (•)
    if [[ -z "$line" || "$line" != •* ]]; then
        continue
    fi

    # Extract event title and calendar (e.g., "stage (INSA)")
    if [[ "$line" =~ ^•\ ([^(]+)\ \(([^)]+)\)$ ]]; then
        event_title="${BASH_REMATCH[1]}"
        event_calendar="${BASH_REMATCH[2]}"
        read -r next_line  # Read the next line for dates/times

        # Split the line into start and end parts using " - " as delimiter
        start_str="${next_line%% - *}"
        end_str="${next_line#* - }"

        # Parse start date/time into epoch seconds
#        echo "parsing start_str: '$start_str'" >&2
        start_epoch=$(parse_date_to_epoch "$start_str")
        # Extract the date part from start_str for use as reference for end_str if needed
        if [[ "$start_str" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
            start_date="${BASH_REMATCH[1]}"
        else
            start_date=$(date +%Y-%m-%d)  # Fallback to today if no date in start_str
        fi

        # Parse end date/time into epoch seconds, using start_date as reference if end_str is time-only
#        echo "parsing end_str: '$end_str' with reference date '$start_date'" >&2
        end_epoch=$(parse_date_to_epoch "$end_str" "$start_date")

        # Convert to minutes (optional, if needed)
        start_epoch_minutes=$((start_epoch / 60))
        end_epoch_minutes=$((end_epoch / 60))

        if (( start_epoch <= current_epoch && current_epoch < end_epoch )); then
            # start <= now < end
            is_current=true
            delta_seconds=$((end_epoch - current_epoch))
            delta_text="Fin $(format_time_delta "$delta_seconds")"
        elif (( start_epoch < current_epoch )); then
            # start < now >= end
            is_current=true
            delta_seconds=$((current_epoch - start_epoch))
            delta_text="Depuis $(format_time_delta -$delta_seconds)"
        else
            # now < start
            is_current=false
            delta_seconds=$((start_epoch - current_epoch))
            delta_text="Début $(format_time_delta "$delta_seconds")"
        fi

        color=$(get_calendar_color "$event_calendar")
        truncated_title=$(truncate_title "$event_title")

#        echo "---
#Titre: $event_title
#Calendrier: $event_calendar ($color)
#Début (epoch): $start_epoch ($start_epoch_minutes minutes)
#Fin (epoch): $end_epoch ($end_epoch_minutes minutes)
#En cours: ${is_current:-false}
#Delta: $delta_text
#---
#"

        sketchybar --set calendar_title label="$truncated_title" \
                   --set calendar_time label="$delta_text" \
                   --set calendar_title label.color="$color"


        # sleep (30s / nb_events) for events to be evenly spaced in time
        sleep $((30 / nb_events))

    fi
done <<< "$events"
