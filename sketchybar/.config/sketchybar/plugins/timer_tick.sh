#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"
TIMER_FILE="/tmp/skb_timer"

if [ ! -f "$TIMER_FILE" ]; then
  sketchybar --set timer drawing=off update_freq=30
  exit 0
fi

END=$(cat "$TIMER_FILE")
NOW=$(date +%s)
REMAINING=$((END - NOW))

if [ "$REMAINING" -gt 0 ]; then
  MINS=$((REMAINING / 60))
  SECS=$((REMAINING % 60))
  sketchybar --set timer label="$(printf '%dm%02ds' $MINS $SECS)" drawing=on update_freq=1
else
  # Timer done — sound + notification
  rm -f "$TIMER_FILE"
  afplay /System/Library/Sounds/Glass.aiff &
  osascript -e 'display notification "Timer finished!" with title "⏱ Timer" sound name "Glass"' 2>/dev/null
  sketchybar --set timer label="done!" drawing=on
  sleep 4
  sketchybar --set timer drawing=off update_freq=30
fi
