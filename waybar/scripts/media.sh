#!/bin/bash
# Media module for waybar — shows current track from any MPRIS player (Cider, etc.)
# Output: JSON for waybar custom module

PLAYER=$(playerctl --list-all 2>/dev/null | head -1)

if [[ -z "$PLAYER" ]]; then
    echo '{"text": "", "class": "inactive"}'
    exit 0
fi

STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)

if [[ "$STATUS" == "Playing" ]]; then
    ICON="<span rise='1000'></span>"
elif [[ "$STATUS" == "Paused" ]]; then
    ICON="<span rise='1000'></span>"
else
    echo '{"text": "", "class": "inactive"}'
    exit 0
fi

ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)

if [[ -z "$TITLE" ]]; then
    echo '{"text": "", "class": "inactive"}'
    exit 0
fi

# Truncate long strings
MAX=30
if [[ -n "$ARTIST" ]]; then
    LABEL="$ARTIST — $TITLE"
else
    LABEL="$TITLE"
fi

if [[ ${#LABEL} -gt $MAX ]]; then
    LABEL="${LABEL:0:$MAX}…"
fi

TEXT="$ICON  $LABEL"
TOOLTIP="$ARTIST\n$TITLE\n$PLAYER"

printf '{"text": "%s", "tooltip": "%s", "class": "%s", "escape": false}\n' \
    "$TEXT" "$TOOLTIP" "${STATUS,,}"
