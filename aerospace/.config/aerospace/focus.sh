#!/usr/bin/env bash
# Navigate the focused terminal's tmux panes; leave tmux at a window edge.
# focus-events must be enabled in tmux so hidden terminal clients are excluded.
set -u

DIR="${1:-}"
case "$DIR" in
  left)  EDGE=left;   FLAG=-L ;;
  down)  EDGE=bottom; FLAG=-D ;;
  up)    EDGE=top;    FLAG=-U ;;
  right) EDGE=right;  FLAG=-R ;;
  *) printf 'Usage: %s left|down|up|right\n' "$0" >&2; exit 2 ;;
esac

FOCUS=$(aerospace list-windows --focused \
  --format '%{window-id}|%{app-bundle-id}|%{app-pid}' 2>/dev/null) || exit 1
IFS='|' read -r WINDOW_ID APP_ID APP_PID <<< "$FOCUS"

still_focused() {
  [ "$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)" = "$WINDOW_ID" ]
}

case "$APP_ID" in
  com.mitchellh.ghostty|org.alacritty)
    CLIENTS=$(tmux list-clients -F \
      "#{client_pid}|#{client_flags}|#{pane_id}|#{pane_at_$EDGE}|#{window_zoomed_flag}" \
      2>/dev/null) || CLIENTS=''

    # Other apps can attach to the same server. Match the client's process
    # ancestry to this terminal app, then require one focused client.
    # If focus is ambiguous, leave tmux alone instead of guessing.
    TARGET=$(awk -v app_pid="$APP_PID" '
      NR == FNR { parent[$1] = $2; next }
      {
        split($0, fields, "[|]")
        if (fields[2] !~ /(^|,)focused(,|$)/) next
        pid = fields[1]
        for (depth = 0; depth < 128 && pid > 1; depth++) {
          if (pid == app_pid) {
            target = fields[3] "|" fields[4] "|" fields[5]
            matches++
            break
          }
          if (!(pid in parent) || parent[pid] == pid) break
          pid = parent[pid]
        }
      }
      END { if (matches == 1) print target }
    ' <(ps -axo pid=,ppid=) <(printf '%s\n' "$CLIENTS"))

    if [ -n "$TARGET" ]; then
      IFS='|' read -r PANE_ID AT_EDGE ZOOMED <<< "$TARGET"
      if [ "$AT_EDGE" = 0 ] && [ "$ZOOMED" = 0 ]; then
        still_focused || exit 0
        tmux select-pane -t "$PANE_ID" "$FLAG" && exit 0
      fi
    fi
    ;;
esac

# Do not wrap to the opposite tmux pane at an edge or reveal a zoomed-out pane.
# Avoid moving a different app if focus changed while the script was running.
still_focused || exit 0
exec aerospace focus --boundaries all-monitors-outer-frame "$DIR"
