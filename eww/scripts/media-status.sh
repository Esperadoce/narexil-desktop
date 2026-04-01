#!/bin/bash
# Returns play/pause icon based on playerctl status
STATUS=$(playerctl status 2>/dev/null)
case "$STATUS" in
  Playing) echo "⏸" ;;
  Paused)  echo "▶" ;;
  *)       echo "" ;;
esac
