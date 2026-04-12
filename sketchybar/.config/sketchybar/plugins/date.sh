#!/usr/bin/env bash
sketchybar --set "$NAME" label="$(date '+%b%-d' | tr '[:upper:]' '[:lower:]')"
