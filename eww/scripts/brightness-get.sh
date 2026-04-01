#!/bin/bash
# Usage: brightness-get.sh <bus>
# Outputs current brightness value (0-100)
BUS=$1
ddcutil getvcp 10 --bus "$BUS" 2>/dev/null | grep -oP 'current value =\s*\K\d+'
