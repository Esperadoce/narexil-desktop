#!/usr/bin/env bash
# Toggle NordVPN on/off

STATUS=$(nordvpn status 2>/dev/null | grep -i "^Status:" | awk '{print $2}')

if [ "$STATUS" = "Connected" ]; then
    nordvpn disconnect
else
    nordvpn connect
fi
