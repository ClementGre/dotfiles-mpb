#!/bin/bash

# Get vm_stat output
vm_output=$(vm_stat)

# Parse page size (default to 16384 if parsing fails)
page_size=$(echo "$vm_output" | grep "page size of" | awk '{print $8}' | tr -d '.')
if [ -z "$page_size" ]; then
    page_size=16384
fi

# Parse memory values
active=$(echo "$vm_output" | grep "Pages active:" | awk '{print $3}' | tr -d '.')
wired=$(echo "$vm_output" | grep "Pages wired down:" | awk '{print $4}' | tr -d '.')
compressed=$(echo "$vm_output" | grep "Pages occupied by compressor:" | awk '{print $5}' | tr -d '.')

# Calculate usage in GB (with one decimal place)
usage=$(echo "scale=1; ($active + $wired + $compressed) * $page_size / 1073741824" | bc)

# Display result
sketchybar -m --set ram_percentage label="${usage}"
