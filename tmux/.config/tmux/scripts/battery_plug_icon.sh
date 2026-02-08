#!/usr/bin/env bash

set -euo pipefail

ONLINE_ICON="${BATTERY_PLUG_ICON:-⚡}"
ONLINE_COLOR="${BATTERY_PLUG_COLOR_ON:-#a6e3a1}"
OFFLINE_COLOR="${BATTERY_PLUG_COLOR_OFF:-#f38ba8}"

source_line="$(pmset -g batt 2>/dev/null | head -n 1 || true)"
if [[ "$source_line" == *"AC Power"* || "$source_line" == *"UPS Power"* ]]; then
  printf "#[fg=%s]%s" "$ONLINE_COLOR" "$ONLINE_ICON"
else
  printf "#[fg=%s]%s" "$OFFLINE_COLOR" "$ONLINE_ICON"
fi
