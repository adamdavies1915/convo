# convo 🖖

**Star Trek Computer for Claude Code** — Claude speaks a one-sentence summary of every response aloud.

You ask a question. Claude responds with text on screen. Your Mac speaks the headline. Like the Enterprise computer.

## Demo

```
You: "What's wrong with the auth module?"

Claude (on screen):
🔊 The token refresh has a race condition when two requests arrive simultaneously.

The issue is in src/auth/refresh.ts at line 47...

(spoken): "The token refresh has a race condition when two requests arrive simultaneously."
```

## How it works

1. A `CLAUDE.md` instruction tells Claude to start every response with a `🔊` summary line
2. A `SessionStart` hook launches a background daemon that watches the transcript file
3. When a `🔊` line appears, it's extracted and spoken via macOS `say`

## Requirements

- macOS Ventura or later (uses the built-in `say` command)
- [Claude Code](https://claude.ai/code)
- `jq` (usually pre-installed, or `brew install jq`)
- Works on both Intel and Apple Silicon Macs

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

macOS has high-quality Siri neural voices that sound dramatically better than the standard voices. These use Apple's neural TTS engine and work on both Intel and Apple Silicon Macs — no Neural Engine required.

1. Open **System Settings → Accessibility → Spoken Content → System Voice → Manage Voices**
2. Download a Siri voice (we recommend **Siri Voice 4** — clean, composed, great computer vibe)
3. Set it as your **System Voice** (click OK to confirm)
4. That's it — convo uses the system voice by default

> **Note:** Siri voices can't be targeted by name with `say -v`. They only work when set as the system default voice. This is a macOS limitation (Ventura+). convo handles this by omitting the `-v` flag, so whatever you set as system voice is what you'll hear.

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

## Architecture

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

For even faster response in iTerm2 (fires from screen output, not transcript file):

1. Settings → Profiles → Advanced → Triggers
2. Add trigger:
   - Regex: `🔊 (.+)`
   - Action: Run Command
   - Parameters: `say -r 185 \1`
   - Check "Instant"

This fires the instant the text renders on screen. Works alongside the daemon — iTerm2 speaks first, daemon deduplicates and stays silent.

## Future: Majel Barrett voice clone

The ultimate goal is to use Majel Barrett's voice (the actual Star Trek Enterprise computer). There's a [trained RVC model](https://huggingface.co/MrM0dZ/MajelBarret) available, but real-time voice cloning requires Apple Silicon for acceptable performance. Options for when you're on an M-series Mac:

- **XTTS v2** — zero-shot voice cloning from a short audio sample (~1-2s per sentence on Apple Silicon)
- **Qwen3-TTS via MLX** — native Apple Silicon TTS with voice cloning (~100ms first packet)
- **RVC pipeline** — use the trained Majel model to convert any TTS output into her voice

PRs welcome if you get any of these working!

## License

MIT
