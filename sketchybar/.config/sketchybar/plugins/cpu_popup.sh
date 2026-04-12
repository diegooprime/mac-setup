#!/usr/bin/env bash
# Toggle CPU popup
DRAWING=$(sketchybar --query cpu | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set cpu popup.drawing=off
  exit 0
fi

# Get top 5 processes
TOP=$(ps -Aceo %cpu,comm -r | head -6 | tail -5)
IFS=$'\n' read -r -d '' -a PROCS <<< "$TOP" || true

for i in {0..4}; do
  IDX=$((i + 1))
  if [ -n "${PROCS[$i]}" ]; then
    PCT=$(echo "${PROCS[$i]}" | awk '{print $1}')
    CMD=$(echo "${PROCS[$i]}" | awk '{print $2}')
    sketchybar --set "cpu.top${IDX}" label="${CMD}  ${PCT}%"
  fi
done

# Temperature (if available)
TEMP=$(sudo powermetrics -n 1 -i 100 --samplers smc 2>/dev/null | grep "CPU die" | awk '{print int($4)}')
if [ -n "$TEMP" ]; then
  sketchybar --set cpu.temp label="temp: ${TEMP}°C"
else
  sketchybar --set cpu.temp label=""
fi

sketchybar --set cpu popup.drawing=on
