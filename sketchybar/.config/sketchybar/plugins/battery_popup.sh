#!/usr/bin/env bash
DRAWING=$(sketchybar --query battery | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set battery popup.drawing=off
  exit 0
fi

BATT_INFO=$(pmset -g batt)
PERCENTAGE=$(echo "$BATT_INFO" | grep -o '[0-9]*%' | head -1 | tr -d '%')
CHARGING=$(echo "$BATT_INFO" | grep -c 'AC Power')
TIME_LEFT=$(echo "$BATT_INFO" | grep -o '[0-9]*:[0-9]* remaining' | head -1)
CYCLES=$(system_profiler SPPowerDataType 2>/dev/null | awk '/Cycle Count/ {print $3}')
HEALTH=$(system_profiler SPPowerDataType 2>/dev/null | awk '/Maximum Capacity/ {print $3}')

if [ "$CHARGING" -gt 0 ]; then
  STATUS="${PERCENTAGE}% — Charging ⚡"
else
  STATUS="${PERCENTAGE}% — ${TIME_LEFT:-calculating...}"
fi

sketchybar --set battery.status label="$STATUS"
sketchybar --set battery.health label="Health: ${HEALTH:-100%}"
sketchybar --set battery.cycles label="Cycles: ${CYCLES:-0}"
sketchybar --set battery popup.drawing=on
