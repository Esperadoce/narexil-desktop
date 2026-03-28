#!/bin/bash
# Cycles zoom: 1 → 2 → 4 → 1
STATE_FILE="/tmp/hypr_zoom_level"

current=$(cat "$STATE_FILE" 2>/dev/null || echo "1")

case "$current" in
    1)   next=1.5 ;;
    1.5) next=2.5 ;;
    2.5) next=4   ;;
    *)   next=1   ;;
esac

echo "$next" > "$STATE_FILE"
hyprctl keyword cursor:zoom_factor "$next"
