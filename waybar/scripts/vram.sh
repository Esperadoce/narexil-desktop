#!/bin/bash
IFS=',' read -r used total < <(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits)
used=$(echo "$used" | tr -d ' ')
total=$(echo "$total" | tr -d ' ')
used_g=$(awk "BEGIN {printf \"%.1f\", $used/1024}")
printf '{"text": "%sG", "tooltip": "VRAM: %sMiB / %sMiB"}' "$used_g" "$used" "$total"
