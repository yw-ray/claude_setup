# Claude Code Environment Setup

Personal Claude Code configuration — rules, commands, skills, memory, status line, and helper scripts.

## Status Line

The status line (model name, context-window %, session / weekly / model-specific rate limits, session cost) is based on **[JungHoonGhae/claude-statusline](https://github.com/JungHoonGhae/claude-statusline)**. The bundled `statusline.sh`, `statusline.conf`, `statusline-command.sh`, and `ccusage-cache.sh` are a vendored copy so this repo alone is enough to bootstrap a new machine. For newer upstream features, pull from that repo and overwrite these files.

Runtime requirement: `jq` must be installed (`apt install jq` on Debian/Ubuntu, `brew install jq` on macOS). Without it, the status line falls back to `Unknown` / `0%`.

## Quick Setup

```bash
# Clone
git clone https://github.com/yw-ray/claude_setup.git
cd claude_setup

# One-shot install (copies everything into ~/.claude/ and rewrites paths)
./setup.sh
```

`setup.sh` copies each payload directory, installs the status line scripts, and rewrites the hardcoded `/home/youngwoo.jeong` path inside `settings.json` to the current `$HOME` so it works on any user account.

### Manual setup (if you prefer)

```bash
cp -r rules/ commands/ docs/ agents/ skills/ scripts/ ~/.claude/
cp AGENTS.md statusline.sh statusline.conf statusline-command.sh ccusage-cache.sh ~/.claude/

# Rewrite paths and drop in settings.json
sed "s|/home/youngwoo.jeong|$HOME|g" settings.json > ~/.claude/settings.json

chmod +x ~/.claude/statusline.sh ~/.claude/scripts/*
```

### Optional: per-project memory

```bash
# memory/ in this repo is an example set for a research project.
# Copy into the project you actually want it attached to:
mkdir -p ~/.claude/projects/<escaped-project-path>/memory/
cp memory/*.md ~/.claude/projects/<escaped-project-path>/memory/
```

### Optional: research agent pipeline

```bash
cp research/CLAUDE.md /path/to/research/
cp -r research/commands/ /path/to/research/.claude/commands/
```

### Optional: git wrappers

```bash
# Installs claude-git, a git block wrapper, and a 'git claude' alias.
bash ~/.claude/scripts/install.sh
```

## What's Included

| Path | Count | Description |
|------|-------|-------------|
| `rules/` | 10 | Coding style & workflow rules (Django, React, Airflow, TDD, etc.) |
| `commands/` | 24 | Git + workflow commands (new, switch, sync, fork, review, ve-*, slides, etc.) |
| `docs/` | 2 | Personal dev workflow & venv guide |
| `agents/` | 5 | Code reviewer agents (neutral, critical, positive, git, PR) |
| `skills/` | 30+ | Text-based skills (plan-eng-review, ship, investigate, etc.) |
| `scripts/` | 6 | Helper scripts (`clone`, `sync`, `git-wrapper`, `install.sh`, etc.) |
| `statusline.*`, `ccusage-cache.sh` | 4 | Status line renderer (vendored from [JungHoonGhae/claude-statusline](https://github.com/JungHoonGhae/claude-statusline)) referenced by `settings.json` |
| `memory/` | 7 | Persistent project context & user preferences (example set) |
| `research/` | 8 | Research agent pipeline (architect, writer, reviewer, etc.) |

## What's NOT Included

- **`plugins/`** — Plugin marketplace cache. Claude Code auto-clones `anthropics/claude-plugins-official` on first use, and `blocklist.json` must be fetched from the server (never commit a stale copy).
- **Browser-based skills** (`browse`, `gstack` binary) — auto-installed on first use per their own flows.
- **Credentials** (`.credentials.json`) — run `claude login` on the new machine.
- **Local settings** (`settings.local.json`) — machine-specific, create manually.
- **Conversation history, sessions, todos, caches, telemetry** — not portable.

## Notes

- `settings.json` in the repo hardcodes `/home/youngwoo.jeong/.claude/statusline.sh` as the status line command. `setup.sh` rewrites this to `$HOME/.claude/statusline.sh` at install time. If you install manually, remember to run the `sed` replacement shown above.
- `scripts/sync-agents-to-cursor` defaults `CURSOR_WIN=/mnt/c/home/sh/.cursor` — override via env var if your Windows/WSL path differs.
