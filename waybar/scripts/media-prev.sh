#!/bin/bash
status=$(playerctl status 2>/dev/null)
[[ "$status" == "Playing" || "$status" == "Paused" ]] && echo '{"text": "󰒮"}' || echo '{"text": ""}'
