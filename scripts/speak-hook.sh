#!/bin/bash
# SessionStart hook — reads transcript path, launches watcher daemon, exits immediately.

HOOK_INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | /usr/bin/jq -r '.transcript_path // empty' 2>/dev/null || true)

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# Launch daemon fully detached — all FDs closed, subshell + background
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
(
  bash "$SCRIPT_DIR/speak-daemon.sh" "$TRANSCRIPT_PATH" </dev/null >/dev/null 2>&1 &
)
exit 0
