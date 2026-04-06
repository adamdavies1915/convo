# convo 🖖

**Star Trek Computer for Claude Code** — Claude speaks a one-sentence summary of every response aloud.

You ask a question. Claude responds with text on screen. Your Mac speaks the headline. Like the Enterprise computer.

## How it works

1. A `CLAUDE.md` instruction tells Claude to start every response with a `🔊` summary line
2. A `SessionStart` hook launches a background daemon that watches the transcript file
3. When a `🔊` line appears, it's extracted and spoken via macOS `say`

```
You: "What's wrong with the auth module?"

Claude (on screen):
🔊 The token refresh has a race condition when two requests arrive simultaneously.

The issue is in src/auth/refresh.ts at line 47...

(spoken): "The token refresh has a race condition when two requests arrive simultaneously."
```

## Requirements

- macOS (uses the built-in `say` command)
- [Claude Code](https://claude.ai/code)
- `jq` (usually pre-installed, or `brew install jq`)

## Install

```bash
git clone https://github.com/adamdavies1915/convo.git
cd convo
bash install.sh
```

Start a new Claude Code session — that's it.

## Uninstall

```bash
bash uninstall.sh
```

## Voice setup

### Recommended: Siri voices (best quality)

macOS has high-quality Siri neural voices that sound dramatically better than the standard voices. To use one:

1. Open **System Settings → Accessibility → Spoken Content → System Voice → Manage Voices**
2. Download a Siri voice (e.g. Siri Voice 1 or Voice 4)
3. Set it as your **System Voice** (click OK to confirm)
4. That's it — convo uses the system voice by default

> **Note:** Siri voices can't be targeted by name with `say -v`. They only work when set as the system default. This is a macOS limitation (Ventura+).

### Alternative: Standard voices

If you prefer a specific named voice, set the `CONVO_VOICE` environment variable in your `.zshrc` or `.bashrc`:

```bash
export CONVO_VOICE=Daniel
```

Run `say -v '?'` to see all available voices.

| Voice | Language | Vibe |
|-------|----------|------|
| Daniel | British English | Composed, officer-like |
| Samantha | US English | Clear, natural, warm |
| Karen | Australian English | Professional, crisp |

### Speed

Default speech rate is 185 words per minute. Adjust with:

```bash
export CONVO_RATE=175   # slower
export CONVO_RATE=210   # faster
```

## How it works (technical)

```
SessionStart hook
  → speak-hook.sh (reads transcript path, exits in ~30ms)
    → speak-daemon.sh (background: tail -f transcript.jsonl)
      → detects 🔊 lines in real-time
        → say "summary"
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
   - Parameters: `say -r 185 \1`
   - Check "Instant"

## License

MIT
