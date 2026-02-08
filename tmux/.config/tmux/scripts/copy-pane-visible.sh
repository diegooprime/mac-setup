#!/usr/bin/env bash

# Copy everything that's currently visible in the active tmux pane.
set -euo pipefail

pane_target="${TMUX_PANE:-}"
if [[ -z "$pane_target" ]]; then
  pane_target="$(tmux display -p "#{pane_id}")"
fi

copy_command=()
if command -v pbcopy >/dev/null 2>&1; then
  copy_command=(pbcopy)
elif command -v wl-copy >/dev/null 2>&1; then
  copy_command=(wl-copy)
elif command -v xclip >/dev/null 2>&1; then
  copy_command=(xclip -selection clipboard)
elif command -v xsel >/dev/null 2>&1; then
  copy_command=(xsel --clipboard --input)
fi

if [[ ${#copy_command[@]} -eq 0 ]]; then
  tmux display-message "copy-pane-visible: no clipboard utility found"
  exit 1
fi

pane_height="$(tmux display-message -p -t "$pane_target" "#{pane_height}")"
if [[ -z "$pane_height" || ! "$pane_height" =~ ^[0-9]+$ ]]; then
  tmux display-message "copy-pane-visible: could not determine pane height"
  exit 1
fi

if (( pane_height <= 0 )); then
  tmux display-message "copy-pane-visible: pane height is invalid"
  exit 1
fi

start_line="-$pane_height"
selection="$(tmux capture-pane -e -p -J -t "$pane_target" -S "$start_line" -E -1)"

if [[ -z "$selection" ]]; then
  tmux display-message "copy-pane-visible: nothing to copy"
  exit 0
fi

printf '%s\n' "$selection" | "${copy_command[@]}"
tmux display-message "Copied visible pane to clipboard"
