#!/bin/bash
# Usage: brightness-set.sh <bus> <value>
BUS=$1
VALUE=$2
# Clamp 0-100
VALUE=$(( VALUE < 0 ? 0 : VALUE > 100 ? 100 : VALUE ))
ddcutil setvcp 10 "$VALUE" --bus "$BUS"
