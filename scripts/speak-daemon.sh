#!/bin/bash
# Long-running watcher — tails the transcript JSONL and speaks 🔊 lines via say.
# Launched by speak-hook.sh, runs as a background daemon for the session lifetime.

TRANSCRIPT_PATH="$1"

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# Configurable voice settings via environment variables
# Empty default = use system voice (supports Siri voices set as system default)
CONVO_VOICE="${CONVO_VOICE:-}"
CONVO_RATE="${CONVO_RATE:-185}"

# Track what we've already spoken to avoid repeats
SPOKEN_FILE="/tmp/convo-spoken-$$"
touch "$SPOKEN_FILE"
trap 'rm -f "$SPOKEN_FILE"' EXIT

tail -f "$TRANSCRIPT_PATH" 2>/dev/null | while IFS= read -r line; do
  # Only process assistant text blocks
  if echo "$line" | grep -q '"role":"assistant"' 2>/dev/null; then
    TEXT=$(echo "$line" | /usr/bin/jq -r '.message.content[]? | select(.type == "text") | .text' 2>/dev/null || true)
    if [[ -n "$TEXT" ]]; then
      SUMMARY=$(echo "$TEXT" | grep -m1 '^🔊 ' | sed 's/^🔊 //' || true)
      if [[ -n "$SUMMARY" ]] && [[ ${#SUMMARY} -gt 4 ]]; then
        # Deduplicate — don't speak the same summary twice
        HASH=$(echo "$SUMMARY" | md5 -q 2>/dev/null || echo "$SUMMARY" | md5sum 2>/dev/null | cut -d' ' -f1)
        if ! grep -q "$HASH" "$SPOKEN_FILE" 2>/dev/null; then
          echo "$HASH" >> "$SPOKEN_FILE"
          # Strip markdown artifacts
          SUMMARY=$(echo "$SUMMARY" | sed 's/`//g; s/\*//g; s/#//g' | cut -c1-200)
          # Kill any in-progress speech to avoid overlap
          killall say 2>/dev/null || true
          if [[ -n "$CONVO_VOICE" ]]; then
            say -v "$CONVO_VOICE" -r "$CONVO_RATE" "$SUMMARY" &
          else
            say -r "$CONVO_RATE" "$SUMMARY" &
          fi
        fi
      fi
    fi
  fi
done
