#!/bin/bash

osascript -e 'quit app "Twingate"'

sleep 1
bash "$CONFIG_DIR/plugins/vpn_twingate.sh"

# Open Twingate again to keep it ready for the next use
#open -a Twingate

