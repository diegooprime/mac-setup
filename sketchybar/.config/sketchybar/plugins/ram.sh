#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

TOTAL_BYTES=$(sysctl -n hw.memsize)
TOTAL_GB=$(echo "$TOTAL_BYTES" | awk '{printf "%.0f", $1/1073741824}')
PAGESIZE=$(sysctl -n hw.pagesize)

USED_PAGES=$(vm_stat | awk '
  /Pages active/    {gsub(/\./,"",$3); a=$3}
  /Pages wired/     {gsub(/\./,"",$4); w=$4}
  /occupied by compressor/ {gsub(/\./,"",$6); c=$6}
  END {print a+w+c}
')

USED_GB=$(echo "$USED_PAGES $PAGESIZE" | awk '{printf "%.1f", $1*$2/1073741824}')
PCT=$(echo "$USED_GB $TOTAL_GB" | awk '{printf "%d", ($1/$2)*100}')

if [ "$PCT" -gt 90 ]; then
  COLOR="$CF_SKB_ACCENT"
elif [ "$PCT" -gt 75 ]; then
  COLOR="$CF_SKB_YELLOW"
else
  COLOR="$CF_SKB_WHITE"
fi

sketchybar --set "$NAME" label="${PCT}%" label.color="$COLOR"
