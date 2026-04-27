#!/usr/bin/env bash
TITLE=$(nowplaying-cli get title 2>/dev/null)
PLAYBACK_RATE=$(nowplaying-cli get playbackRate 2>/dev/null)

if [ -n "$TITLE" ] && [ "$TITLE" != "null" ] && [ "$PLAYBACK_RATE" != "0" ] && [ "$PLAYBACK_RATE" != "null" ]; then
  sketchybar --set "$NAME" label="$TITLE" drawing=on
else
  sketchybar --set "$NAME" label="" drawing=off
fi
