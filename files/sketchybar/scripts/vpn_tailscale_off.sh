#!/bin/bash

/Applications/Tailscale.app/Contents/MacOS/Tailscale down

bash "$CONFIG_DIR/plugins/vpn_tailscale.sh"
