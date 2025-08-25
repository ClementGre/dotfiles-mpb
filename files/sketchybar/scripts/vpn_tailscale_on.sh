#!/bin/bash

/Applications/Tailscale.app/Contents/MacOS/Tailscale up

bash "$CONFIG_DIR/plugins/vpn_tailscale.sh"
