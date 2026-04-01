#!/bin/bash
# Background daemon — refreshes brightness cache every 5s
# One instance only, run via eww autostart
LOCK="/tmp/eww-brightness-daemon.lock"

exec 9>"$LOCK"
flock -n 9 || exit 1  # exit if already running

refresh() {
  ddcutil getvcp 10 --bus 1 --sleep-multiplier 0.1 2>/dev/null \
    | grep -oP 'current value =\s*\K\d+' > /tmp/eww-brightness-1 &
  ddcutil getvcp 10 --bus 2 --sleep-multiplier 0.1 2>/dev/null \
    | grep -oP 'current value =\s*\K\d+' > /tmp/eww-brightness-2 &
  ddcutil getvcp 10 --bus 3 --sleep-multiplier 0.1 2>/dev/null \
    | grep -oP 'current value =\s*\K\d+' > /tmp/eww-brightness-3 &
  wait
}

# Init cache immediately
refresh

while true; do
  sleep 5
  refresh
done
