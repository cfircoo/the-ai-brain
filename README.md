# The AI Brain

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](.claude-plugin/plugin.json)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-orange.svg)](https://claude.ai/code)
[![Cursor](https://img.shields.io/badge/Cursor-supported-purple.svg)](https://cursor.sh)
[![Gemini CLI](https://img.shields.io/badge/Gemini%20CLI-supported-blue.svg)](https://github.com/google-gemini/gemini-cli)
[![OpenAI Codex](https://img.shields.io/badge/OpenAI%20Codex-supported-412991.svg)](https://openai.com)
[![Obsidian CLI](https://img.shields.io/badge/Obsidian%20CLI-1.12%2B-7C3AED.svg)](https://obsidian.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/cfircoo/the-ai-brain/pulls)

A universal persistent memory system for AI agents. Install into any directory or Obsidian vault to give your AI agent long-term memory, self-improving behavior, and structured workflows.

## Prerequisites

| Requirement | Required? | Notes |
|-------------|-----------|-------|
| [Claude Code](https://claude.ai/code) | **Required** | For hooks, skills, and full memory features |
| `git` | **Required** | For version control of your vault |
| `jq` | **Required** | For JSON processing in hooks |
| [Obsidian 1.12+](https://obsidian.md/download) | Optional | Unlocks CLI mode — 70,000x faster vault search. Without it, brain uses raw file reads (still fully functional) |
| `yq` | Optional | Better YAML parsing. Falls back to `awk` if missing |
| `python3` | Optional | Used by hooks when Obsidian CLI is active |

**Obsidian CLI setup** (if you want it):
1. Install [Obsidian](https://obsidian.md/download) 1.12+
2. Open Obsidian → Settings → General → enable **Command Line Interface**
3. Click **Register CLI** — adds `obsidian` to your system PATH
4. Run `obsidian version` in terminal to verify
5. The brain auto-detects it during `install.sh`

> Obsidian is **not required**. The brain works on any plain directory with raw markdown files.

## Supported Agents

| Agent | Config File | Hooks | Skills | Memory |
|-------|-----------|-------|--------|--------|
| Claude Code | CLAUDE.md | Mechanical (hooks) | /brain-today, /brain-new, /brain-tldr, etc. | Full |
| Cursor | .cursorrules | Instruction-based | N/A | Instruction-based |
| Gemini CLI | GEMINI.md | Instruction-based | N/A | Instruction-based |
| OpenAI Codex | AGENTS.md | Instruction-based | N/A | Instruction-based |

## Install

### Option 1: Claude Code Plugin Marketplace (Recommended)

From within any Claude Code session:

```
/plugin marketplace add cfircoo/the-ai-brain
/plugin install the-ai-brain@cfircoo
```

Then initialize the brain in your vault:

```
/the-ai-brain:brain-setup
```

### Option 2: Load as Local Plugin

```bash
# Clone the repo
git clone https://github.com/cfircoo/the-ai-brain.git

# Launch Claude Code with the plugin loaded
claude --plugin-dir ./the-ai-brain
```

Skills are available as `/the-ai-brain:brain-today`, `/the-ai-brain:brain-debrief`, etc.

### Option 3: Standalone Installer

```bash
git clone https://github.com/cfircoo/the-ai-brain.git
cd the-ai-brain
bash install.sh /path/to/your/vault
```

The installer will:
1. Auto-detect your role from git/README (no questions if context is clear)
2. Ask your preferred architecture (Hub+Spokes default — press Enter)
3. Create the vault directory structure
4. Generate agent-specific config files
5. Install hooks and skills (Claude Code)
6. Wire the hub if Hub+Spokes was chosen

**Adding a brain to an existing project:**
```bash
cd ~/projects/your-existing-project
# Then in Claude Code:
/the-ai-brain:brain-setup
# Auto-detects context, defaults to Hub+Spokes
```

## Architecture Strategies

### Hub + Spokes (default, recommended)

One global brain for your identity + per-project brains for local context. Both are always in context simultaneously.

```
~/Brain/                         ← HUB (your personal OS)
├── Human/Daily/                 ← daily notes, life captures
├── Machine/Memory/
│   ├── entities.md              ← people, tools — across ALL projects
│   ├── decisions.md             ← life/career decisions
│   └── projects.md              ← registry of all known projects
└── CLAUDE.md                    ← who you are, global rules

~/.claude/CLAUDE.md              ← loads ~/Brain on EVERY session

~/projects/my-app/               ← SPOKE (project-specific)
├── .brain/                      ← local memory, hooks
└── CLAUDE.md                    ← project rules + references ~/Brain

~/projects/other-project/        ← another SPOKE
└── CLAUDE.md                    ← references ~/Brain automatically
```

**Setup:** Run `/the-ai-brain:brain-setup` in any project — Hub+Spokes is the default. Existing projects with no brain? Same command, it auto-detects context from your git/README.

### Per-Project (isolated)

Each project has its own brain with no shared memory. Good for completely unrelated projects or team repos.

### Centralized (one vault)

Everything in `~/Brain/`. One Obsidian vault, one graph view. Good for a personal knowledge OS without coding projects.

---

## How It Works

```
┌─────────────────────────────────────────────┐
│  Your Vault / Knowledge Base                 │
│                                              │
│  Human/          ← YOUR content (protected)  │
│    Daily/        ← Daily notes               │
│    Projects/     ← Project files             │
│    Archive/      ← Completed items           │
│                                              │
│  Machine/        ← AI-managed content        │
│    Memory/       ← Persistent memory files   │
│    Rules/        ← Self-updating rules       │
│    Session-Logs/ ← Session continuity        │
│    Templates/    ← Note templates            │
│                                              │
│  .brain/         ← Brain engine metadata     │
│  CLAUDE.md       ← Agent config (generated)  │
└─────────────────────────────────────────────┘
```

### The Memory Stack

| Layer | What | How |
|-------|------|-----|
| **CLAUDE.md** | Rules, structure, startup protocol | Auto-loaded every session |
| **Hooks** | Mechanical enforcement | Fire automatically (Claude Code) |
| **Session Logs** | What happened last session | Written at end, read at start |
| **Memory Files** | Entities, decisions, corrections | Updated continuously |
| **Active Rules** | Behavioral rules (self-updating) | AI proposes, you approve |

## Obsidian CLI Integration

When [Obsidian 1.12+](https://obsidian.md) is installed with the CLI enabled (Settings → General → Command Line Interface), the brain automatically upgrades from raw file reads to Obsidian's internal search index.

| Method | Token cost for 4,000-file vault | Capabilities |
|--------|--------------------------------|--------------|
| Raw file reads (default) | ~7M tokens for orphan scan | File contents only |
| **Obsidian CLI (enhanced)** | **~100 tokens** | Search index, backlinks, tasks, orphans, canvases |

> Benchmark by developer Boxin Proof: 70,000x token reduction on orphan detection.

### Setup (30 seconds)

1. Install [Obsidian](https://obsidian.md/download) 1.12+
2. Open Obsidian → Settings → General → enable **Command Line Interface**
3. Click **Register CLI** — Obsidian adds itself to your system PATH
4. Run `obsidian version` in terminal to verify
5. Re-run `bash install.sh` on your vault — CLI is auto-detected

### What changes with the CLI

- `session-start.sh` uses `obsidian tasks todo format=json` for real task lists
- `/brain-vault-audit` uses `obsidian orphans format=json` for instant orphan detection
- `/brain-today` uses `obsidian daily` / `obsidian daily:read` for native daily note integration
- `/brain-canvas` creates `.canvas` files and opens them in Obsidian instantly

### Official skills by kepano

The Obsidian CEO ([kepano](https://github.com/kepano)) published official Claude Code skills at `kepano/obsidian-typhoon-skills`. These complement the brain with low-level CLI command knowledge. Install both:

```bash
# Install kepano's official Obsidian CLI skills
git clone https://github.com/kepano/obsidian-typhoon-skills.git
cp obsidian-typhoon-skills/skills/* ~/.claude/skills/

# Then install the-ai-brain for persistent memory + workflows
bash install.sh ~/your-vault
```

### The Self-Improving Loop

```
You correct the AI → Logged to corrections.md →
/brain-reflect analyzes patterns → Proposes rule changes →
active-rules.md updated → Agent configs regenerated →
Next session: AI behaves better → Repeat
```

## Commands (Claude Code)

| Command | Description |
|---------|-------------|
| `/brain-today` | Morning startup - loads context, plans your day |
| `/brain-new` | Brain-dump triage - routes raw input to correct files |
| `/brain-tldr` | Summarize a session, file, or topic |
| `/brain-debrief` | End-of-session ritual - logs session, updates memory |
| `/brain-vault-audit` | Health check - orphans, stale files, consistency |
| `/brain-vault-align` | Re-sync agent configs from brain.yaml |
| `/brain-reflect` | AI self-review - analyzes patterns, proposes improvements |
| `/brain-ingest` | Import external content with proper formatting |
| `/brain-canvas` | Create Obsidian JSON Canvas visualizations |
| `/brain-seed` | Enrich the knowledge graph - creates MOC hubs, entity notes, cross-links |

## Architecture

### Single Source of Truth

All agent configs are generated from two files:

```
brain.yaml          ← Your preferences, structure, enabled agents
core/brain-rules.md ← Universal behavioral rules
        │
        ├─→ CLAUDE.md      (Claude Code)
        ├─→ .cursorrules   (Cursor)
        ├─→ GEMINI.md      (Gemini CLI)
        └─→ AGENTS.md      (OpenAI Codex)
```

Edit `brain.yaml`, run `/brain-vault-align`, and all agents update.

### Hooks (Claude Code)

Hooks provide **mechanical enforcement** - they fire automatically, the AI can't skip them:

- **SessionStart** → Injects last session context, active rules, today's note
- **Stop** → Reminds AI to write session log
- **PostToolUse (Write/Edit)** → Detects rule changes, triggers re-sync

### Memory Files

Located in `Machine/Memory/`:

- **entities.md** - People, projects, tools, preferences
- **decisions.md** - Past decisions with rationale
- **corrections.md** - Every time you correct the AI
- **context-cache.md** - Frequently referenced context

### Vault Permissions

- `Human/` → AI can **read** but only **writes when explicitly asked**
- `Machine/` → AI reads and writes freely
- This prevents AI-generated content from contaminating your authentic notes

## Updating

Re-run the installer to update an existing brain:

```bash
bash install.sh /path/to/your/vault
# Select "Update/re-sync existing brain"
```

Or from within a brain-enabled vault:

```
/brain-vault-align
```

## Uninstalling

```bash
rm -rf /path/to/vault/.brain
rm -rf /path/to/vault/.claude
rm /path/to/vault/CLAUDE.md
rm /path/to/vault/.cursorrules
rm /path/to/vault/GEMINI.md
rm /path/to/vault/AGENTS.md
# Machine/ and Human/ directories contain your data - remove manually if desired
```

## License

MIT
