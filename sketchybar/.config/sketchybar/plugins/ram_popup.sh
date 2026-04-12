#!/usr/bin/env bash
DRAWING=$(sketchybar --query ram | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set ram popup.drawing=off
  exit 0
fi

# Parse vm_stat
PAGESIZE=$(sysctl -n hw.pagesize)
TOTAL_BYTES=$(sysctl -n hw.memsize)
TOTAL_GB=$(echo "$TOTAL_BYTES" | awk '{printf "%.1f", $1/1073741824}')

eval "$(vm_stat | awk -v ps="$PAGESIZE" '
  /Pages active/    {gsub(/\./,"",$3); printf "ACTIVE_GB=%.1f\n", $3*ps/1073741824}
  /Pages wired/     {gsub(/\./,"",$4); printf "WIRED_GB=%.1f\n", $4*ps/1073741824}
  /Pages occupied by compressor/ {gsub(/\./,"",$6); printf "COMP_GB=%.1f\n", $6*ps/1073741824}
  /Swapouts/        {gsub(/\./,"",$2); printf "SWAP=%d\n", $2*ps/1048576}
')"

USED_GB=$(echo "$ACTIVE_GB $WIRED_GB $COMP_GB" | awk '{printf "%.1f", $1+$2+$3}')

sketchybar --set ram.used label="Used: ${USED_GB} / ${TOTAL_GB} GB"
sketchybar --set ram.app label="App: ${ACTIVE_GB} GB  Wired: ${WIRED_GB} GB"
sketchybar --set ram.wired label="Compressed: ${COMP_GB} GB"
sketchybar --set ram.swap label="Swap: ${SWAP:-0} MB"
sketchybar --set ram popup.drawing=on
