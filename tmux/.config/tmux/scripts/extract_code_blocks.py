#!/usr/bin/env python3
"""Extract copyable items (code blocks, commands, paths, URLs) from Claude Code conversations."""
import glob
import json
import os
import re
import sys


def find_latest_jsonl():
    pattern = os.path.expanduser("~/.claude/projects/*/*.jsonl")
    files = glob.glob(pattern)
    if not files:
        return None
    return max(files, key=os.path.getmtime)


def extract_items(jsonl_path):
    items = []  # list of (type_label, content)
    seen = set()

    with open(jsonl_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            if obj.get("type") != "assistant":
                continue

            msg = obj.get("message")
            if not isinstance(msg, dict):
                continue

            for part in msg.get("content", []):
                if not isinstance(part, dict) or part.get("type") != "text":
                    continue
                text = part["text"]

                # 1. Fenced code blocks
                for m in re.finditer(r"```\w*\n(.*?)```", text, re.DOTALL):
                    code = m.group(1).strip()
                    if code and code not in seen:
                        seen.add(code)
                        items.append(("CODE", code))

                # Remove fenced blocks for further scanning
                remaining = re.sub(r"```\w*\n.*?```", "", text, flags=re.DOTALL)

                # 2. Inline code (between single backticks)
                for m in re.finditer(r"`([^`\n]+)`", remaining):
                    val = m.group(1).strip()
                    if len(val) < 5 or val in seen:
                        continue
                    # Skip plain English words
                    if re.match(r"^[a-zA-Z]+$", val) and len(val) < 20:
                        continue
                    seen.add(val)
                    if val.startswith(("/", "~/", "./")):
                        items.append(("PATH", val))
                    elif re.match(r"https?://", val):
                        items.append(("URL", val))
                    elif " " in val or val.startswith((
                        "sudo ", "npm ", "git ", "claude ", "pip ", "brew ",
                        "cargo ", "docker ", "kubectl ", "tmux ", "cd ",
                        "mkdir ", "cp ", "mv ", "export ",
                    )):
                        items.append(("CMD", val))
                    else:
                        items.append(("REF", val))

                # Remove inline code for further scanning
                remaining = re.sub(r"`[^`\n]+`", "", remaining)

                # 3. URLs in plain text
                for m in re.finditer(r"https?://[^\s\)\]>\"']+", remaining):
                    url = m.group(0).rstrip(".,;:")
                    if url not in seen and len(url) > 10:
                        seen.add(url)
                        items.append(("URL", url))

                # 4. Paths in plain text
                for m in re.finditer(
                    r"(?:~/|/(?:Users|home|tmp|var|etc|opt|usr))[/\w\-\.@]+",
                    remaining,
                ):
                    path = m.group(0).rstrip(".,;:")
                    if path not in seen and len(path) > 5:
                        seen.add(path)
                        items.append(("PATH", path))

    return items


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "last"

    jsonl_path = find_latest_jsonl()
    if not jsonl_path:
        sys.exit(1)

    items = extract_items(jsonl_path)
    if not items:
        sys.exit(1)

    if mode == "last":
        sys.stdout.write(items[-1][1])

    elif mode == "fzf":
        tmpdir = sys.argv[2] if len(sys.argv) > 2 else None
        if not tmpdir:
            sys.exit(1)
        for i, (label, content) in enumerate(items):
            with open(os.path.join(tmpdir, str(i)), "w") as f:
                f.write(content)
            first_line = content.splitlines()[0][:70]
            n_lines = len(content.splitlines())
            if n_lines > 1:
                print(f"{i}\t[{label}] [{n_lines}L] {first_line}")
            else:
                print(f"{i}\t[{label}] {first_line}")


if __name__ == "__main__":
    main()
