#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

# Query ActivityWatch for today's total screen time
TODAY=$(date '+%Y-%m-%d')
TOMORROW=$(date -v+1d '+%Y-%m-%d')

# Find the window watcher bucket
BUCKET=$(curl -s http://localhost:5600/api/0/buckets 2>/dev/null | python3 -c "
import json,sys
try:
  d=json.load(sys.stdin)
  for k in d:
    if 'aw-watcher-window' in k:
      print(k)
      break
except: pass
" 2>/dev/null)

if [ -z "$BUCKET" ]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

# Get today's events and sum duration
HOURS=$(curl -s "http://localhost:5600/api/0/buckets/${BUCKET}/events?start=${TODAY}T00:00:00&end=${TOMORROW}T00:00:00&limit=-1" 2>/dev/null | python3 -c "
import json,sys
try:
  events=json.load(sys.stdin)
  total=sum(e.get('duration',0) for e in events)
  h=int(total//3600)
  m=int((total%3600)//60)
  print(f'{h}h{m:02d}m')
except: print('--')
" 2>/dev/null)

[ -z "$HOURS" ] && HOURS="--"

sketchybar --set "$NAME" label="$HOURS"
