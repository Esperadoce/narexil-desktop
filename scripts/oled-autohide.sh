#!/usr/bin/env bash
# Monitors cursor position and auto-shows/hides the OLED waybar.
# Shows bar when cursor reaches top edge of HDMI-A-1, hides after HIDE_DELAY ms.

MONITOR="HDMI-A-1"
HIDE_DELAY=2000  # ms before hiding after cursor leaves top zone
POLL_MS=80       # polling interval in ms

ms() { date +%s%3N; }

# Get monitor bounds
read -r MON_X MON_W < <(hyprctl monitors -j | jq -r \
    '.[] | select(.name == "'"$MONITOR"'") | "\(.x) \(.width)"')
MON_RIGHT=$((MON_X + MON_W))

# Wait for waybar to start then hide the bar
sleep 1.5
pkill -SIGUSR1 -f "waybar.*config-oled" 2>/dev/null || true
VISIBLE=false
LEAVE_MS=0

while true; do
    sleep "0.$(printf '%03d' $POLL_MS)"

    json=$(hyprctl cursorpos -j 2>/dev/null) || continue
    cx=$(printf '%s' "$json" | jq -r '.x')
    cy=$(printf '%s' "$json" | jq -r '.y')
    now=$(ms)

    if (( cy <= 4 && cx >= MON_X && cx < MON_RIGHT )); then
        # Cursor at top edge of OLED
        if ! $VISIBLE; then
            pkill -SIGUSR1 -f "waybar.*config-oled" 2>/dev/null || true
            VISIBLE=true
        fi
        LEAVE_MS=0
    else
        # Cursor not in zone
        if $VISIBLE; then
            if (( LEAVE_MS == 0 )); then
                LEAVE_MS=$((now + HIDE_DELAY))
            elif (( now >= LEAVE_MS )); then
                pkill -SIGUSR1 -f "waybar.*config-oled" 2>/dev/null || true
                VISIBLE=false
                LEAVE_MS=0
            fi
        fi
    fi
done
