#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

TOTAL_BYTES=$(sysctl -n hw.memsize)
PAGESIZE=$(sysctl -n hw.pagesize)
TOTAL_GB=$(awk -v bytes="$TOTAL_BYTES" 'BEGIN {printf "%.1f", bytes/1073741824}')
PAGEABLE=$(sysctl -n vm.page_pageable_internal_count)
PURGEABLE=$(sysctl -n vm.page_purgeable_count)

read -r WIRED_PAGES COMP_PAGES FREE_PAGES SPEC_PAGES <<EOF
$(vm_stat | awk '
  /Pages wired down/             {gsub(/\./,"",$NF); w=$NF}
  /Pages occupied by compressor/ {gsub(/\./,"",$NF); c=$NF}
  /Pages free/                   {gsub(/\./,"",$NF); f=$NF}
  /Pages speculative/            {gsub(/\./,"",$NF); s=$NF}
  END {print w+0, c+0, f+0, s+0}
')
EOF

APP_PAGES=$((PAGEABLE - PURGEABLE))
USED_GB=$(awk -v app="$APP_PAGES" -v wired="$WIRED_PAGES" -v comp="$COMP_PAGES" -v ps="$PAGESIZE" 'BEGIN {printf "%.1f", (app+wired+comp)*ps/1073741824}')
FREE_GB=$(awk -v free="$FREE_PAGES" -v spec="$SPEC_PAGES" -v ps="$PAGESIZE" 'BEGIN {printf "%.1f", (free+spec)*ps/1073741824}')
COMP_GB=$(awk -v comp="$COMP_PAGES" -v ps="$PAGESIZE" 'BEGIN {printf "%.1f", comp*ps/1073741824}')
PRESSURE_FREE=$(memory_pressure 2>/dev/null | awk -F': ' '/System-wide memory free percentage/ {gsub(/%/,"",$2); print int($2)}')
SWAP_USED_MB=$(sysctl -n vm.swapusage | awk -F'used = |M  free' '{printf "%d", $2}')

if [ -z "$PRESSURE_FREE" ]; then
  PRESSURE_FREE=$(awk -v free="$FREE_GB" -v total="$TOTAL_GB" 'BEGIN {printf "%d", (free/total)*100}')
fi

if [ "$SWAP_USED_MB" -ge 2048 ] || [ "$PRESSURE_FREE" -le 10 ]; then
  COLOR="$CF_SKB_ACCENT"
elif [ "$SWAP_USED_MB" -gt 0 ] || [ "$PRESSURE_FREE" -le 25 ] || awk -v comp="$COMP_GB" 'BEGIN {exit !(comp >= 2.0)}'; then
  COLOR="$CF_SKB_YELLOW"
else
  COLOR="$CF_SKB_WHITE"
fi

sketchybar --set "$NAME" label="${USED_GB}G" label.color="$COLOR" icon.color="$COLOR"
