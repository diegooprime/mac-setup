#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

BATT_INFO=$(pmset -g batt)
PCT=$(echo "$BATT_INFO" | grep -o '[0-9]*%' | head -1 | tr -d '%')
CHARGING=$(echo "$BATT_INFO" | grep -c 'AC Power')

[ -z "$PCT" ] && PCT=100

# Green = plugged in, white = unplugged, yellow = low, red = critical
if [ "$CHARGING" -gt 0 ]; then
  COLOR="$CF_SKB_GREEN"
elif [ "$PCT" -le 15 ]; then
  COLOR="$CF_SKB_ACCENT"
elif [ "$PCT" -le 30 ]; then
  COLOR="$CF_SKB_YELLOW"
else
  COLOR="$CF_SKB_TEXT"
fi

sketchybar --set "$NAME" label="${PCT}%" label.color="$COLOR"
