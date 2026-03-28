#!/usr/bin/env bash
# NordVPN status module for Waybar

STATUS=$(nordvpn status 2>/dev/null)
STATE=$(echo "$STATUS" | grep -i "^Status:" | awk '{print $2}')

if [ "$STATE" = "Connected" ]; then
    CITY=$(echo "$STATUS"    | grep -i "^City:"    | cut -d: -f2 | xargs)
    COUNTRY=$(echo "$STATUS" | grep -i "^Country:" | cut -d: -f2 | xargs)
    IP=$(echo "$STATUS"      | grep -i "^IP:"      | cut -d: -f2 | xargs)
    SERVER=$(echo "$STATUS"  | grep -i "^Hostname:" | cut -d: -f2 | xargs)
    echo "{\"text\": \"<span rise='1000'>󰒃</span>  ${CITY}\", \"tooltip\": \"Connected — ${COUNTRY}, ${CITY}\\nIP: ${IP}\\nServer: ${SERVER}\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"󰦝\", \"tooltip\": \"NordVPN disconnected\", \"class\": \"disconnected\"}"
fi
