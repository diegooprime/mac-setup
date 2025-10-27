#!/usr/bin/env bash

# Copy the latest output block from the current tmux pane to the system clipboard.
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
  tmux display-message "copy-visible-pane: no clipboard utility found"
  exit 1
fi

history_lines="${TMUX_COPY_HISTORY_LINES:-5000}"
if [[ ! "$history_lines" =~ ^[0-9]+$ ]]; then
  history_lines=5000
fi
if [[ "$history_lines" -le 0 ]]; then
  history_lines=5000
fi

selection="$(
  tmux capture-pane -p -J -S "-$history_lines" -t "$pane_target" | \
    TMUX_COPY_PROMPT_REGEX="${TMUX_COPY_PROMPT_REGEX:-}" python3 <<'PY'
import os
import re
import sys

content = sys.stdin.read()
if not content:
    sys.exit(0)

lines = content.splitlines()
clean_lines = []
osc_re = re.compile(r"\x1b\].*?(?:\x07|\x1b\\)")
csi_re = re.compile(r"\x1b\[[0-9;?]*[ -/]*[@-~]")

for line in lines:
    cleaned = osc_re.sub("", line)
    cleaned = csi_re.sub("", cleaned)
    cleaned = cleaned.replace("\r", "")
    clean_lines.append(cleaned)

prompt_pattern = os.environ.get(
    "TMUX_COPY_PROMPT_REGEX",
    r".*[%#$>\u276f\u203a\u03bb\u279c]\s*$",
)

try:
    regex = re.compile(prompt_pattern)
except re.error as err:
    sys.stderr.write(f"Invalid TMUX_COPY_PROMPT_REGEX: {err}\n")
    regex = re.compile(r".*[%#$>\u276f\u203a\u03bb\u279c]\s*$")

last_prompt = None
for idx in range(len(clean_lines) - 1, -1, -1):
    if regex.fullmatch(clean_lines[idx].rstrip()):
        last_prompt = idx
        break

if last_prompt is None:
    for idx in range(len(clean_lines) - 1, -1, -1):
        if clean_lines[idx].strip():
            sys.stdout.write(lines[idx])
            sys.exit(0)
    if lines:
        sys.stdout.write(lines[-1])
    sys.exit(0)

prev_prompt = None
for idx in range(last_prompt - 1, -1, -1):
    if regex.fullmatch(clean_lines[idx].rstrip()):
        prev_prompt = idx
        break

start = (prev_prompt + 1) if prev_prompt is not None else 0
end = last_prompt

while start < end and not clean_lines[start].strip():
    start += 1
while end > start and not clean_lines[end - 1].strip():
    end -= 1

selected = lines[start:end]

if not selected and prev_prompt is not None:
    selected = [lines[prev_prompt]]

if not selected:
    for idx in range(len(clean_lines) - 1, -1, -1):
        if clean_lines[idx].strip():
            selected = [lines[idx]]
            break
    else:
        if lines:
            selected = [lines[-1]]

sys.stdout.write("\n".join(selected))
PY
)"

if [[ -z "$selection" ]]; then
  tmux display-message "copy-visible-pane: nothing to copy"
  exit 0
fi

printf '%s' "$selection" | "${copy_command[@]}"
tmux display-message "Copied last output block to clipboard"
