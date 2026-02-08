#!/usr/bin/env bash

set -euo pipefail

RAM_SCRIPT="$HOME/.config/tmux/plugins/tmux-cpu/scripts/ram_percentage.sh"

print_from_tmux_cpu() {
  local raw value
  raw="$("$RAM_SCRIPT")" || return 1
  value="$(printf "%s" "$raw" | tr -d '%[:space:]')" || return 1
  awk -v used="$value" 'BEGIN { printf "%3.1f%%", 100 - used }'
}

print_from_memory_pressure() {
  local free
  free="$(memory_pressure -Q 2>/dev/null | awk -F': ' '/System-wide memory free percentage/ {gsub(/%/, "", $2); print $2; exit}')" || return 1
  if [[ -z "$free" ]]; then
    return 1
  fi
  awk -v value="$free" 'BEGIN { printf "%3.1f%%", 100 - value }'
}

if [[ -x "$RAM_SCRIPT" ]]; then
  if ! print_from_tmux_cpu; then
    print_from_memory_pressure || echo "n/a"
  fi
else
  print_from_memory_pressure || echo "n/a"
fi
