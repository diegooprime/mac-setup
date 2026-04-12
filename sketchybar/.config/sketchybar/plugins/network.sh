#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

# Simple connectivity check — green dot if connected, red if not
IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -n "$IP" ]; then
  sketchybar --set "$NAME" icon="●" icon.color="$CF_SKB_GREEN"
else
  sketchybar --set "$NAME" icon="●" icon.color="$CF_SKB_ACCENT"
fi
