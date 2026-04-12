#!/usr/bin/env bash
# Smart focus: if in terminal with tmux, navigate panes. Otherwise, Aerospace focus.
DIR="$1"
APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)

if [ "$APP" = "Ghostty" ] || [ "$APP" = "Alacritty" ]; then
  # Check if tmux is running, then navigate panes directly
  if tmux display-message -p '#{session_name}' &>/dev/null; then
    case "$DIR" in
      left)  tmux select-pane -L ;;
      down)  tmux select-pane -D ;;
      up)    tmux select-pane -U ;;
      right) tmux select-pane -R ;;
    esac
  else
    aerospace focus "$DIR" 2>/dev/null
  fi
else
  aerospace focus "$DIR" 2>/dev/null
fi
