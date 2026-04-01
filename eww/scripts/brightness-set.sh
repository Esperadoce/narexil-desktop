#!/bin/bash
# Usage: brightness-set.sh <bus> <value>
# Debounced per-bus — rapid calls collapse into one ddcutil write
BUS=$1
VALUE=$(echo "$2" | cut -d. -f1)
VALUE=$(( VALUE < 1 ? 1 : VALUE > 100 ? 100 : VALUE ))

PENDING="/tmp/eww-brightness-pending-${BUS}"
LOCK="/tmp/eww-brightness-set-${BUS}.lock"

# Write the latest desired value
echo "$VALUE" > "$PENDING"

# Update cache immediately so the slider feels responsive
echo "$VALUE" > "/tmp/eww-brightness-${BUS}"

# If a setter is already waiting for this bus, let it pick up our value
exec 9>"$LOCK"
flock -n 9 || exit 0

# We got the lock — wait for slider to settle, then apply final value
(
  sleep 0.3
  FINAL=$(cat "$PENDING")
  ddcutil setvcp 10 "$FINAL" --bus "$BUS" --sleep-multiplier 0.1 2>/dev/null
  echo "$FINAL" > "/tmp/eww-brightness-${BUS}"
) &
disown
