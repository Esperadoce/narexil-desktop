#!/bin/bash
count=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:magic")] | length')
if [ "$count" -gt 0 ]; then
    printf '{"text": "󱂬  %s", "tooltip": "%s window(s) in scratchpad", "class": "active"}' "$count" "$count"
else
    printf '{"text": ""}'
fi
