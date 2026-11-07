#!/bin/bash
# Claude Code status line relay for quotabar.
#
# Claude Code only gives the plan usage (`rate_limits`) to the status line command, on stdin.
# This relay saves that JSON for quotabar, then hands the same input to your real status line.

input=$(cat)

# Only overwrite the saved data when it holds the limits: they are missing before the first response of a session.
if [[ "$input" == *'"rate_limits"'* ]]; then
    out_dir="$HOME/Library/Application Support/quotabar"
    mkdir -p "$out_dir"
    # Write then rename, so quotabar never reads a half-written file.
    printf '%s' "$input" > "$out_dir/statusline.json.tmp" && mv "$out_dir/statusline.json.tmp" "$out_dir/statusline.json"
fi

# Your real status line goes here; it receives the same JSON on stdin. Leave it empty to print nothing.
next_statusline() {
    :
}

printf '%s' "$input" | next_statusline
