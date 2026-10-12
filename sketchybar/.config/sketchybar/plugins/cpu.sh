#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

CORES=$(sysctl -n hw.ncpu)
CPU=$(ps -A -o %cpu= | awk -v cores="$CORES" '{sum += $1} END {printf "%.0f", sum / cores}')
[ "$CPU" -gt 100 ] && CPU=100

if [ "$CPU" -gt 85 ]; then
  COLOR="$CF_SKB_ACCENT"
elif [ "$CPU" -gt 60 ]; then
  COLOR="$CF_SKB_YELLOW"
else
  COLOR="$CF_SKB_WHITE"
fi

sketchybar --set "$NAME" label="${CPU}%" label.color="$COLOR" icon.color="$COLOR"
