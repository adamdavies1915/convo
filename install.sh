#!/bin/bash
set -euo pipefail

# convo — Star Trek Computer for Claude Code
# Installs voice response hooks and CLAUDE.md instructions.

CONVO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

echo "🖖 Installing convo — Star Trek Computer for Claude Code"
echo ""

# Ensure directories exist
mkdir -p "$SCRIPTS_DIR"

# Copy scripts
cp "$CONVO_DIR/scripts/speak-hook.sh" "$SCRIPTS_DIR/speak-hook.sh"
cp "$CONVO_DIR/scripts/speak-daemon.sh" "$SCRIPTS_DIR/speak-daemon.sh"
chmod +x "$SCRIPTS_DIR/speak-hook.sh" "$SCRIPTS_DIR/speak-daemon.sh"
echo "✓ Scripts installed to $SCRIPTS_DIR"

# Add hook to settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
  # Check if hook already exists
  if grep -q "speak-hook.sh" "$SETTINGS_FILE" 2>/dev/null; then
    echo "✓ Hook already configured in settings.json"
  else
    # Merge hook into existing settings
    UPDATED=$(cat "$SETTINGS_FILE" | /usr/bin/jq '.hooks.SessionStart = [{"matcher": "", "hooks": [{"type": "command", "command": "bash ~/.claude/scripts/speak-hook.sh", "timeout": 3}]}]')
    echo "$UPDATED" | /usr/bin/jq '.' > "$SETTINGS_FILE"
    echo "✓ Hook added to $SETTINGS_FILE"
  fi
else
  cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/scripts/speak-hook.sh",
            "timeout": 3
          }
        ]
      }
    ]
  }
}
SETTINGS
  echo "✓ Created $SETTINGS_FILE with hook config"
fi

# Append voice instruction to CLAUDE.md if not already present
VOICE_MARKER="## Voice Response (Star Trek Computer Mode)"
if [[ -f "$CLAUDE_MD" ]] && grep -q "$VOICE_MARKER" "$CLAUDE_MD" 2>/dev/null; then
  echo "✓ Voice instructions already in CLAUDE.md"
else
  cat >> "$CLAUDE_MD" << 'CLAUDEMD'

## Voice Response (Star Trek Computer Mode)

Every response MUST begin with a spoken summary line:

🔊 [One natural sentence, under 25 words, summarizing the response]

Rules:
- First line of every response, starts with 🔊 emoji + space
- Single sentence, natural when spoken aloud
- No code, backticks, markdown formatting, or special characters
- No filler ("Sure!", "Great question!") — direct, like a ship's computer
- Tone: calm, factual, informative
- After the 🔊 line, blank line, then full detailed response
- If the response IS one sentence, the 🔊 line is the whole response
CLAUDEMD
  echo "✓ Voice instructions appended to $CLAUDE_MD"
fi

echo ""
echo "🎙  convo installed! Start a new Claude Code session to hear Daniel."
echo ""
echo "   Customize voice:  export CONVO_VOICE=Samantha"
echo "   Customize speed:  export CONVO_RATE=210"
echo "   Uninstall:        bash $(dirname "$0")/uninstall.sh"
