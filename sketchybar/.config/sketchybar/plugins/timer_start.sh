#!/usr/bin/env bash
MINS=${1:-5}
END=$(($(date +%s) + MINS * 60))
echo "$END" > /tmp/skb_timer

# Close popup, show timer item, set fast updates
sketchybar --set clock popup.drawing=off
sketchybar --set timer drawing=on update_freq=1
