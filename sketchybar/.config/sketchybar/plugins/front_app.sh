#!/usr/bin/env bash
APP="$INFO"

if [ -z "$APP" ]; then
  APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
fi

sketchybar --set "$NAME" label="$APP"
