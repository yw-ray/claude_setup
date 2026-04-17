# Claude Code Environment Setup

Personal Claude Code configuration — rules, commands, skills, memory.

## Quick Setup

```bash
# Clone
git clone https://github.com/yw-ray/claude_setup.git
cd claude_setup

# Copy to ~/.claude/
cp -r rules/ ~/.claude/rules/
cp -r commands/ ~/.claude/commands/
cp -r docs/ ~/.claude/docs/
cp -r agents/ ~/.claude/agents/
cp -r skills/ ~/.claude/skills/
cp AGENTS.md ~/.claude/
cp settings.json ~/.claude/

# Memory (adjust project path as needed)
mkdir -p ~/.claude/projects/<your-project-path>/memory/
cp memory/*.md ~/.claude/projects/<your-project-path>/memory/

# Research project (if using research agent pipeline)
cp research/CLAUDE.md /path/to/research/
cp -r research/commands/ /path/to/research/.claude/commands/
```

## What's Included

| Directory | Count | Description |
|-----------|-------|-------------|
| `rules/` | 10 | Coding style & workflow rules (Django, React, Airflow, TDD, etc.) |
| `commands/` | 13 | Git workflow commands (new, switch, sync, fork, review, etc.) |
| `docs/` | 2 | Personal dev workflow & venv guide |
| `agents/` | 5 | Code reviewer agents (neutral, critical, positive, git, PR) |
| `skills/` | 30+ | Text-based skills (plan-eng-review, ship, investigate, etc.) |
| `memory/` | 7 | Persistent project context & user preferences |
| `research/` | 8 | Research agent pipeline (architect, writer, reviewer, etc.) |

## What's NOT Included

- **Browser-based skills** (browse, gstack binary) — auto-installed on first use
- **Credentials** (.credentials.json) — run `claude login` on new machine
- **Local settings** (settings.local.json) — machine-specific, create manually
- **Conversation history** — not portable
