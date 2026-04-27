#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

AUDIO_BIN="$HOME/.config/sketchybar/bin/current_audio_output"
AUDIO_SRC="$HOME/.config/sketchybar/bin/current_audio_output.swift"

if [ ! -x "$AUDIO_BIN" ] || [ "$AUDIO_SRC" -nt "$AUDIO_BIN" ]; then
  swiftc "$AUDIO_SRC" -o "$AUDIO_BIN" 2>/dev/null
fi

OUTPUT_INFO=$("$AUDIO_BIN" output 2>/dev/null)

if [ "$OUTPUT_INFO" = "blue" ]; then
  sketchybar --set "$NAME" drawing=on label.drawing=off
else
  sketchybar --set "$NAME" drawing=off label.drawing=off
fi
