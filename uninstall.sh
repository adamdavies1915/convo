#!/bin/bash
set -euo pipefail

# convo — uninstaller

CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

echo "Uninstalling convo..."

# Kill running daemons
pkill -f speak-daemon 2>/dev/null || true
rm -f /tmp/convo-spoken-* 2>/dev/null

# Remove scripts
rm -f "$SCRIPTS_DIR/speak-hook.sh" "$SCRIPTS_DIR/speak-daemon.sh"
echo "✓ Scripts removed"

# Remove hook from settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
  UPDATED=$(cat "$SETTINGS_FILE" | /usr/bin/jq 'del(.hooks.SessionStart[] | select(.hooks[]?.command | test("speak-hook")))')
  # Clean up empty arrays
  UPDATED=$(echo "$UPDATED" | /usr/bin/jq 'if .hooks.SessionStart == [] then del(.hooks.SessionStart) else . end')
  UPDATED=$(echo "$UPDATED" | /usr/bin/jq 'if .hooks == {} then del(.hooks) else . end')
  echo "$UPDATED" | /usr/bin/jq '.' > "$SETTINGS_FILE"
  echo "✓ Hook removed from settings.json"
fi

# Remove voice instruction block from CLAUDE.md
if [[ -f "$CLAUDE_MD" ]]; then
  # Remove the voice section (from marker to next ## or end of file)
  sed -i '' '/^## Voice Response (Star Trek Computer Mode)/,/^## [^V]/{ /^## [^V]/!d; }' "$CLAUDE_MD" 2>/dev/null || true
  # Clean up trailing whitespace
  sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD" 2>/dev/null || true
  echo "✓ Voice instructions removed from CLAUDE.md"
fi

echo ""
echo "convo uninstalled. Silence is golden... but less fun."
