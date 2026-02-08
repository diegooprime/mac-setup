#!/usr/bin/env bash
# Copy the most recent code block from the active Claude Code session.
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

block="$(python3 "$script_dir/extract_code_blocks.py" last 2>/dev/null)" || {
    tmux display-message "No code block found"
    exit 0
}

if [[ -z "$block" ]]; then
    tmux display-message "No code block found"
    exit 0
fi

printf '%s' "$block" | pbcopy
# Show first 40 chars as confirmation
preview="${block:0:40}"
preview="${preview//$'\n'/ }"
tmux display-message "Copied: ${preview}..."
