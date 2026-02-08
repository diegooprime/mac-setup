#!/usr/bin/env bash
# Show all code blocks from the active Claude Code session in fzf for selection.
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

labels="$(python3 "$script_dir/extract_code_blocks.py" fzf "$tmpdir" 2>/dev/null)" || {
    printf "No code blocks found. Press any key."
    read -r -n1
    exit 0
}

if [[ -z "$labels" ]]; then
    printf "No code blocks found. Press any key."
    read -r -n1
    exit 0
fi

selected="$(printf '%s' "$labels" | tac | fzf \
    --delimiter=$'\t' \
    --with-nth=2.. \
    --preview="cat '${tmpdir}'/{1}" \
    --preview-window=right:60%:wrap \
    --no-sort \
    --header='enter: copy  |  esc: cancel  (newest first)' \
    --bind='j:down,k:up,h:preview-up,l:preview-down,q:abort')" || exit 0

[[ -z "$selected" ]] && exit 0

idx="${selected%%	*}"
cat "${tmpdir}/${idx}" | pbcopy
