#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

DRAWING=$(sketchybar --query date | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set date popup.drawing=off
  exit 0
fi

# Use full cal output — already properly formatted monospace
MONTH=$(date '+%B %Y')
# Pad header to match cal width (20 chars) and center it
HEADER=$(printf '%20s' " ")
HEADER="      $MONTH      "

sketchybar --set date.header label="$HEADER"
sketchybar --set date.wk label=" Su Mo Tu We Th Fr Sa "

i=1
while IFS= read -r line || [ -n "$line" ]; do
  if [ $i -le 6 ]; then
    # Pad each row to exactly 22 chars so all rows are same width
    padded=$(printf ' %-20s ' "$line")
    sketchybar --set date.r$i label="$padded" drawing=on
  fi
  i=$((i + 1))
done <<< "$(cal | tail -n +3)"

while [ $i -le 6 ]; do
  sketchybar --set date.r$i label="" drawing=off
  i=$((i + 1))
done

sketchybar --set date popup.drawing=on
