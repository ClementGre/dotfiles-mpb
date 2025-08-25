#!/bin/bash

sudo route delete sslvpn.cisr.fr
sudo kill -INT $(pgrep -af openconnect)

sleep 0.4

bash "$CONFIG_DIR/plugins/vpn_insa.sh"
