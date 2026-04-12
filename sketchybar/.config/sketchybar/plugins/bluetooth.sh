#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

# Check for connected audio devices
HAS_AUDIO=$(system_profiler SPBluetoothDataType 2>/dev/null | awk '
  /Connected:/{found=1; next}
  /Not Connected:/{found=0}
  found && /Minor Type: (Headset|Headphones)/{print "yes"; exit}
')

if [ "$HAS_AUDIO" = "yes" ]; then
  sketchybar --set "$NAME" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
