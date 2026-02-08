#!/usr/bin/env bash

set -euo pipefail

URL="${NETWORK_CHECK_URL:-https://1.1.1.1}"
TIMEOUT="${NETWORK_HTTP_TIMEOUT:-2}"
HOST="${NETWORK_CHECK_HOST:-1.1.1.1}"
PING_WAIT_MS="${NETWORK_PING_WAIT_MS:-1000}"
ONLINE_ICON="${NETWORK_ONLINE_ICON:-●}"
OFFLINE_ICON="${NETWORK_OFFLINE_ICON:-✖}"
ONLINE_COLOR="${NETWORK_ONLINE_COLOR:-#a6e3a1}"
OFFLINE_COLOR="${NETWORK_OFFLINE_COLOR:-#f38ba8}"

have_curl() {
  command -v curl >/dev/null 2>&1
}

have_ping() {
  command -v ping >/dev/null 2>&1
}

if have_curl; then
  if curl --head --fail --insecure --silent \
    --max-time "$TIMEOUT" \
    --connect-timeout "$TIMEOUT" \
    "$URL" >/dev/null 2>&1; then
    printf "#[fg=%s]%s" "$ONLINE_COLOR" "$ONLINE_ICON"
    exit 0
  fi
elif have_ping; then
  if ping -c 1 -W "$PING_WAIT_MS" "$HOST" >/dev/null 2>&1; then
    printf "#[fg=%s]%s" "$ONLINE_COLOR" "$ONLINE_ICON"
    exit 0
  fi
fi

printf "#[fg=%s]%s" "$OFFLINE_COLOR" "$OFFLINE_ICON"
