#!/bin/bash

STATUS=$(/Applications/Tailscale.app/Contents/MacOS/Tailscale status)
if [ "$STATUS" = "Tailscale is stopped." ]; then
    exit 1
else
    exit 0
fi

