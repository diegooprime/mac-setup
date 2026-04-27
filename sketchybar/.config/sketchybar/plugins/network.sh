#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

IFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2; exit}')
[ -z "$IFACE" ] && IFACE=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2; exit}')
[ -z "$IFACE" ] && IFACE="en0"

NOW=$(date +%s)
BYTES=$(netstat -ibn | awk -v iface="$IFACE" '$1 == iface && $7 ~ /^[0-9]+$/ {print $7; exit}')
STATE_FILE="${TMPDIR:-/tmp}/sketchybar-net-${IFACE}.state"

if [ -z "$BYTES" ]; then
  sketchybar --set "$NAME" label="--" label.color="$CF_SKB_ACCENT" icon.color="$CF_SKB_ACCENT"
  exit 0
fi

if [ -f "$STATE_FILE" ]; then
  read -r LAST_TIME LAST_BYTES < "$STATE_FILE"
else
  LAST_TIME=$NOW
  LAST_BYTES=$BYTES
fi

printf '%s %s\n' "$NOW" "$BYTES" > "$STATE_FILE"

DELTA_TIME=$((NOW - LAST_TIME))
DELTA_BYTES=$((BYTES - LAST_BYTES))
[ "$DELTA_TIME" -le 0 ] && DELTA_TIME=1
[ "$DELTA_BYTES" -lt 0 ] && DELTA_BYTES=0

RATE_BPS=$((DELTA_BYTES * 8 / DELTA_TIME))
LABEL=$(awk -v b="$RATE_BPS" 'BEGIN {
  if (b >= 1000000) printf "%.0fM", b / 1000000
  else if (b >= 1000) printf "%.0fK", b / 1000
  else printf "0K"
}')

if ipconfig getifaddr "$IFACE" >/dev/null 2>&1; then
  COLOR="$CF_SKB_WHITE"
else
  COLOR="$CF_SKB_ACCENT"
fi

sketchybar --set "$NAME" label="↓ $LABEL" label.color="$COLOR" icon.color="$CF_SKB_MUTED"
