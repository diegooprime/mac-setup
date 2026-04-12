#!/usr/bin/env bash
DRAWING=$(sketchybar --query network | jq -r '.popup.drawing')
if [ "$DRAWING" = "on" ]; then
  sketchybar --set network popup.drawing=off
  exit 0
fi

SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk '/ SSID/ {print $2}')
IP=$(ipconfig getifaddr en0 2>/dev/null || echo "disconnected")

sketchybar --set network.ssid label="SSID: ${SSID:-unknown}"
sketchybar --set network.ip label="IP: $IP"
sketchybar --set network.speeds label="Interface: en0 (Wi-Fi)"
sketchybar --set network popup.drawing=on
