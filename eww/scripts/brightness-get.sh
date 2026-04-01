#!/bin/bash
# Usage: brightness-get.sh <bus>
# Reads from cache — instant, no DDC hit
BUS=$1
CACHE="/tmp/eww-brightness-${BUS}"
if [[ -f "$CACHE" ]]; then
  cat "$CACHE"
else
  echo "50"
fi
