#!/bin/bash
# Toggle eww dashboard on the monitor where the cursor currently is

if eww active-windows | grep -q "dashboard"; then
  # Animate close then destroy
  eww update panel-closing="true"
  sleep 0.2
  eww close dashboard
  eww update panel-closing="false"
else
  # Detect monitor under cursor
  POS=$(hyprctl cursorpos)
  CX=$(echo "$POS" | awk -F',' '{print int($1)}')
  CY=$(echo "$POS" | awk -F',' '{print int($2)}')

  MONITOR=$(hyprctl monitors -j | jq -r --argjson cx "$CX" --argjson cy "$CY" '
    .[] | select(
      $cx >= .x and $cx < (.x + .width) and
      $cy >= .y and $cy < (.y + .height)
    ) | .name
  ' | head -1)

  [ -z "$MONITOR" ] && MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

  # Get monitor index from name
  SCREEN=$(hyprctl monitors -j | jq -r --arg name "$MONITOR" 'to_entries[] | select(.value.name == $name) | .key')
  [ -z "$SCREEN" ] && SCREEN=0

  eww update panel-closing="false"
  eww open dashboard --screen "$SCREEN"
fi
