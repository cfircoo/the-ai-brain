# Architecture

## Design Principles

1. **Agent-agnostic core** - Brain rules are written once, compiled to each agent's format
2. **Mechanical over instructional** - Hooks enforce behavior; instructions are fallback
3. **Non-destructive** - Installer never overwrites existing files
4. **Plain text** - Everything is markdown. No databases, no lock-in
5. **Vault-scoped** - Brain installs per-vault, not globally

## Component Map

```
the-ai-brain/
├── brain.yaml              ← Config (single source of truth)
├── core/                   ← Agent-agnostic rules and protocols
├── generators/             ← Compile rules → agent-specific configs
├── hooks/                  ← Claude Code mechanical enforcement
├── skills/                 ← Claude Code slash command skills
├── commands/               ← Claude Code command files
├── vault-template/         ← Scaffold for target vault
└── install.sh              ← Entry point
```

## Data Flow

### Session Start
```
Hook fires → session-start.sh
  → Read .brain/state.json (last session timestamp)
  → Read Machine/Session-Logs/ (last 2 logs)
  → Read Machine/Memory/context-cache.md
  → Read Machine/Rules/active-rules.md
  → Read Human/Daily/{today}.md
  → Output JSON with userPromptPrefix (injected context)
```

### During Session
```
User works normally with AI
  → AI reads from Human/ and Machine/ as needed
  → AI writes to Machine/ freely
  → PostToolUse hook monitors for rule changes
```

### Session End
```
User runs /brain-debrief (or Stop hook fires)
  → Write Machine/Session-Logs/{timestamp}.md
  → Update Machine/Memory/ files
  → Update .brain/state.json
```

### Self-Improvement
```
User corrects AI → correction logged
  → /brain-reflect analyzes corrections
  → Proposes changes to active-rules.md
  → /brain-vault-align regenerates all agent configs
```

## Multi-Agent Support

Claude Code gets full mechanical enforcement via hooks.
Other agents get the same rules as strong instructions in their config files.

The asymmetry is intentional - Claude Code's hook system is unique.
Other agents simulate the same behavior through prominent instructions.

## File Ownership

| Path | Owner | Purpose |
|------|-------|---------|
| brain.yaml | User | Master config |
| core/* | Project | Universal rules |
| Machine/Rules/active-rules.md | AI (with approval) | Living rulebook |
| Machine/Memory/* | AI | Persistent memory |
| Machine/Session-Logs/* | AI | Session continuity |
| Human/* | User | Protected content |
| CLAUDE.md, .cursorrules, etc. | Generated | Agent configs |
