#!/bin/bash
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | tr -d ' ')
printf '{"text": "%s%%", "tooltip": "GPU: %s%%"}' "$gpu" "$gpu"
