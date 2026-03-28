# The AI Brain

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](.claude-plugin/plugin.json)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-orange.svg)](https://claude.ai/code)
[![Cursor](https://img.shields.io/badge/Cursor-supported-purple.svg)](https://cursor.sh)
[![Gemini CLI](https://img.shields.io/badge/Gemini%20CLI-supported-blue.svg)](https://github.com/google-gemini/gemini-cli)
[![OpenAI Codex](https://img.shields.io/badge/OpenAI%20Codex-supported-412991.svg)](https://openai.com)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/cfircoo/the-ai-brain/pulls)

A universal persistent memory system for AI agents. Install into any directory or Obsidian vault to give your AI agent long-term memory, self-improving behavior, and structured workflows.

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
1. Ask a few configuration questions (your name, role, which agents you use)
2. Create the vault directory structure
3. Generate agent-specific config files
4. Install hooks and skills (Claude Code)
5. Initialize git for version control

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
