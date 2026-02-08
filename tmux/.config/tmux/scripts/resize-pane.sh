#!/usr/bin/env bash

set -euo pipefail

direction=${1:-grow}
raw_step=${2:-5}

notify() {
  local msg="$1"
  tmux display-message "$msg" >/dev/null 2>&1 || true
}

fail() {
  local msg="$1"
  notify "$msg"
  echo "$msg" >&2
  exit 1
}

percent_mode=0
percent_value=0
step_value=0

if [[ "$raw_step" == *% ]]; then
  percent_mode=1
  percent_value=${raw_step%%%}
  if ! [[ "$percent_value" =~ ^[0-9]+$ ]]; then
    fail "resize-pane.sh: invalid percent '$raw_step'"
  fi
  percent_value=$(( percent_value ))
  if (( percent_value <= 0 )); then
    fail "resize-pane.sh: percent must be greater than 0"
  fi
else
  if ! [[ "$raw_step" =~ ^[0-9]+$ ]]; then
    fail "resize-pane.sh: invalid step '$raw_step'"
  fi
  step_value=$(( raw_step ))
  if (( step_value <= 0 )); then
    step_value=1
  fi
fi

has_neighbor() {
  local pos="$1"
  [[ "$(tmux display-message -p -F "#{pane_at_${pos}}")" == "1" ]]
}

calc_step() {
  local axis="$1"

  if (( percent_mode )); then
    local size=0
    if [[ "$axis" == "horizontal" ]]; then
      size=$(tmux display-message -p "#{pane_width}")
    else
      size=$(tmux display-message -p "#{pane_height}")
    fi

    size=$(( size ))
    local result=$(( size * percent_value / 100 ))
    if (( result < 1 )); then
      result=1
    fi
    echo "$result"
  else
    echo "$step_value"
  fi
}

grow() {
  local step_horizontal
  step_horizontal=$(calc_step horizontal)
  local step_vertical
  step_vertical=$(calc_step vertical)

  if has_neighbor right; then
    tmux resize-pane -R "$step_horizontal"
  elif has_neighbor left; then
    tmux resize-pane -L "$step_horizontal"
  elif has_neighbor bottom; then
    tmux resize-pane -D "$step_vertical"
  else
    tmux resize-pane -U "$step_vertical"
  fi
}

shrink() {
  local step_horizontal
  step_horizontal=$(calc_step horizontal)
  local step_vertical
  step_vertical=$(calc_step vertical)

  if has_neighbor right; then
    tmux resize-pane -L "$step_horizontal"
  elif has_neighbor left; then
    tmux resize-pane -R "$step_horizontal"
  elif has_neighbor bottom; then
    tmux resize-pane -U "$step_vertical"
  else
    tmux resize-pane -D "$step_vertical"
  fi
}

case "$direction" in
  grow)
    grow
    ;;
  shrink)
    shrink
    ;;
  *)
    fail "resize-pane.sh: unknown action '$direction'"
    ;;
esac
