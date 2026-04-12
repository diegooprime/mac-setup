#!/usr/bin/env bash
# Get now-playing via MediaRemote (never launches apps)
TITLE=$(nowplaying-cli get title 2>/dev/null)

if [ -n "$TITLE" ] && [ "$TITLE" != "null" ]; then
  sketchybar --set "$NAME" label="$TITLE" drawing=on
else
  sketchybar --set "$NAME" label="" drawing=off
fi
