#!/usr/bin/env bash
DRAWING=$(sketchybar --query clock | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set clock popup.drawing=off
else
  # Cancel running timer if exists
  if [ -f /tmp/skb_timer ]; then
    sketchybar --set clock.t1 label="Cancel timer" \
      click_script="rm -f /tmp/skb_timer && sketchybar --set timer drawing=off && sketchybar --set clock popup.drawing=off && sketchybar --set clock.t1 label='  1 min' click_script='$HOME/.config/sketchybar/plugins/timer_start.sh 1'"
  fi
  sketchybar --set clock popup.drawing=on
fi
