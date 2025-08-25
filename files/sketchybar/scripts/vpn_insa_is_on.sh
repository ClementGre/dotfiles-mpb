#!/bin/bash

# Warning: checks for any openconnect process, not specifically for INSA VPN.
pgrep -x openconnect > /dev/null
