#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

NCPU=$(sysctl -n hw.ncpu)
CPU=$(ps -A -o %cpu | awk -v n="$NCPU" '{s+=$1}END{printf "%d", s/n}')
[ -z "$CPU" ] && CPU=0
[ "$CPU" -gt 100 ] && CPU=100

if [ "$CPU" -gt 80 ]; then
  COLOR="$CF_SKB_ACCENT"
elif [ "$CPU" -gt 60 ]; then
  COLOR="$CF_SKB_YELLOW"
else
  COLOR="$CF_SKB_WHITE"
fi

sketchybar --set "$NAME" label="${CPU}%" label.color="$COLOR"
