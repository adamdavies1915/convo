# convo 🖖

**Star Trek Computer for Claude Code** — Claude speaks a one-sentence summary of every response aloud.

You ask a question. Claude responds with text on screen. Daniel (or your preferred macOS voice) speaks the headline. Like the Enterprise computer.

## How it works

1. A `CLAUDE.md` instruction tells Claude to start every response with a `🔊` summary line
2. A `SessionStart` hook launches a background daemon that watches the transcript file
3. When a `🔊` line appears, it's extracted and spoken via macOS `say`

```
You: "What's wrong with the auth module?"

Claude (on screen):
🔊 The token refresh has a race condition when two requests arrive simultaneously.

The issue is in src/auth/refresh.ts at line 47...

Daniel (spoken): "The token refresh has a race condition when two requests arrive simultaneously."
```

## Requirements

- macOS (uses the built-in `say` command)
- [Claude Code](https://claude.ai/code)
- `jq` (usually pre-installed, or `brew install jq`)

## Install

```bash
git clone https://github.com/yourusername/convo.git
cd convo
bash install.sh
```

Start a new Claude Code session — that's it.

## Uninstall

```bash
bash uninstall.sh
```

## Configuration

Set environment variables (in your `.zshrc` or `.bashrc`):

```bash
# Change voice (default: Daniel)
export CONVO_VOICE=Samantha

# Change speech rate in words per minute (default: 195)
export CONVO_RATE=210
```

Available voices: run `say -v '?'` to see all installed voices.

Some good options:
| Voice | Language | Vibe |
|-------|----------|------|
| Daniel | British English | Composed, officer-like |
| Samantha | US English | Clear, natural, warm |
| Karen | Australian English | Professional, crisp |

## How it works (technical)

```
SessionStart hook
  → speak-hook.sh (reads transcript path, exits in ~30ms)
    → speak-daemon.sh (background: tail -f transcript.jsonl)
      → detects 🔊 lines in real-time
        → say -v Daniel -r 195 "summary"
```

- **No latency**: daemon watches the transcript file live, speaks the instant the `🔊` line is written
- **No blocking**: hook script exits in ~30ms, daemon is fully detached
- **Deduplication**: MD5 hash tracking prevents repeating the same summary
- **Works everywhere**: iTerm2, VS Code terminal, Terminal.app — anything that runs Claude Code

## Bonus: iTerm2 trigger

For even faster response in iTerm2 (fires from screen output, not transcript):

1. Settings → Profiles → Advanced → Triggers
2. Add trigger:
   - Regex: `🔊 (.+)`
   - Action: Run Command
   - Parameters: `say -v Daniel -r 195 \1`
   - Check "Instant"

## License

MIT
