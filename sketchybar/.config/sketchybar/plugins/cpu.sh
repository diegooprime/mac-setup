#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

read -r USER SYS IDLE <<EOF
$(top -l 2 -n 0 | awk '/^CPU usage:/ {gsub(/%|,/, ""); user=$3; sys=$5; idle=$7} END {printf "%.0f %.0f %.0f", user+0, sys+0, idle+0}')
EOF

CPU=$((USER + SYS))
[ "$CPU" -gt 100 ] && CPU=100

if [ "$CPU" -gt 85 ]; then
  COLOR="$CF_SKB_ACCENT"
elif [ "$CPU" -gt 60 ]; then
  COLOR="$CF_SKB_YELLOW"
else
  COLOR="$CF_SKB_WHITE"
fi

sketchybar --set "$NAME" label="${CPU}%" label.color="$COLOR" icon.color="$COLOR"
