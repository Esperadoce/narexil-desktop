#!/usr/bin/env bash

SHUTDOWN="󰐥  Shutdown"
REBOOT="󰜉  Reboot"
SUSPEND="󰤄  Suspend"
LOGOUT="󰍃  Logout"

CHOICE=$(printf "%s\n%s\n%s\n%s" "$SHUTDOWN" "$REBOOT" "$SUSPEND" "$LOGOUT" \
  | rofi -dmenu \
      -p "Power" \
      -theme ~/.config/rofi/theme.rasi \
      -theme-str 'window { width: 220px; } mainbox { children: [ listview ]; } listview { lines: 4; }')

case "$CHOICE" in
  "$SHUTDOWN") systemctl poweroff ;;
  "$REBOOT")   systemctl reboot ;;
  "$SUSPEND")  systemctl suspend ;;
  "$LOGOUT")   hyprctl dispatch exit ;;
esac
