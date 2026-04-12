#!/usr/bin/env bash
DRAWING=$(sketchybar --query music | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set music popup.drawing=off
  exit 0
fi

TITLE=$(nowplaying-cli get title 2>/dev/null)
ARTIST=$(nowplaying-cli get artist 2>/dev/null)
ALBUM=$(nowplaying-cli get album 2>/dev/null)

sketchybar --set music.title label="${ARTIST:-Unknown} — ${TITLE:-Nothing}"
sketchybar --set music.artist label="${ALBUM:-}"
sketchybar --set music.controls label="⏮  ▶  ⏭"
sketchybar --set music popup.drawing=on
