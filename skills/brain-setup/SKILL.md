---
name: brain-setup
description: Initialize The AI Brain in the current directory. Creates vault structure, memory files, rules, templates, and agent configs.
---

<objective>
Initialize The AI Brain persistent memory system in the current working directory. This creates the full vault architecture (Human/ and Machine/ hemispheres), memory files, session log templates, behavioral rules, and generates agent-specific config files (CLAUDE.md, .cursorrules, GEMINI.md).
</objective>

<protocol>

## Step 1: Check for Existing Brain

Check if `.brain/` directory already exists in the current working directory.
- If it exists, ask the user if they want to re-sync/update or abort.
- If not, proceed with fresh setup.

## Step 2: Gather Configuration

Ask the user these questions (use concise prompts):

1. **Your name** (default: system username)
2. **Your role** (e.g., developer, PM, researcher, student)
3. **Name for this brain** (default: directory name + "Brain")
4. **Which AI agents do you use?** (Claude Code, Cursor, Gemini CLI, Codex - can select multiple)
5. **Use Obsidian format?** (wikilinks + frontmatter, default: yes)

## Step 3: Create Directory Structure

Create the following directories (skip any that already exist):

```
Human/
  Daily/
  Projects/
  Archive/
Machine/
  Session-Logs/
  Memory/
  Rules/
  Templates/
.brain/
  hooks/
  agent-configs/
```

## Step 4: Create Memory Files

Create these files in `Machine/Memory/` (skip if they exist):

**entities.md:**
```markdown
---
date: {{today}}
type: memory
tags: [brain, entities]
---
# Entities

## People

## Projects

## Tools

## Preferences
```

**decisions.md:**
```markdown
---
date: {{today}}
type: memory
tags: [brain, decisions]
---
# Decisions Log

Record architectural and workflow decisions with rationale here.
```

**corrections.md:**
```markdown
---
date: {{today}}
type: memory
tags: [brain, corrections]
---
# Corrections Log

Every correction the user makes to AI behavior is logged here.
```

**context-cache.md:**
```markdown
---
date: {{today}}
type: memory
tags: [brain, context]
---
# Active Context

## Current Focus

## Quick Reference

## Recent Context
```

## Step 5: Create Rules

**Machine/Rules/active-rules.md:**
```markdown
---
date: {{today}}
type: rules
tags: [brain, rules]
---
# Active Rules

1. **Startup**: Read this file, context-cache.md, and latest session log before starting work
2. **Human/ protection**: Read freely, write ONLY when explicitly asked
3. **Machine/ access**: Read and write freely to Machine/ directories
4. **Formatting**: Use [[wikilinks]] and YAML frontmatter on all new files (if Obsidian mode)
5. **Memory**: Log new entities, decisions, and corrections to Machine/Memory/
6. **Session end**: Write a session log to Machine/Session-Logs/ before ending
7. **Self-improve**: When corrected, log to corrections.md and propose a rule update
```

**Machine/Rules/rule-changelog.md:**
```markdown
---
date: {{today}}
type: changelog
tags: [brain, rules]
---
# Rule Changelog

## {{today}} - Initial Setup
- Created default rule set via /the-ai-brain:brain-setup
```

## Step 6: Create Templates

Create these in `Machine/Templates/`:

**daily.md** - Daily note template with frontmatter, sections for tasks, notes, logs
**project.md** - Project template with overview, goals, tasks, notes sections
**session-log.md** - Session log template with summary, decisions, files modified, next steps

## Step 7: Create Brain State

Write `.brain/state.json`:
```json
{
  "brain_version": "1.0.0",
  "installed_at": "{{timestamp}}",
  "last_session": null,
  "sessions_count": 0,
  "active_agent": null
}
```

Write `.brain/brain.yaml` with the user's configuration answers.

## Step 8: Generate Agent Configs

Based on which agents the user selected:

- **Claude Code**: Generate `CLAUDE.md` at vault root with startup protocol, vault structure map, formatting rules, brain rules, and session end instructions.
- **Cursor**: Generate `.cursorrules` with equivalent instructions.
- **Gemini CLI**: Generate `GEMINI.md` with equivalent instructions.
- **Codex**: Generate `AGENTS.md` with equivalent instructions.

The generated CLAUDE.md MUST include:
- About the owner (name, role)
- Vault structure map (all directories explained)
- Startup protocol (read rules, context-cache, last session log, today's note)
- Formatting conventions (wikilinks, frontmatter, date format)
- Directory permissions (Human=read-only, Machine=read-write)
- Memory protocol (log entities, decisions, corrections)
- Session end protocol (write session log)
- Self-improvement protocol (corrections → rules)

## Step 9: Install Hooks (Claude Code only)

If Claude Code was selected, create hook scripts in `.brain/hooks/`:

**session-start.sh** - Reads state.json, last 2 session logs, context-cache, active-rules, today's daily note. Outputs JSON with userPromptPrefix containing concise context summary.

**post-session.sh** - Outputs userPromptSuffix reminding to write session log. Updates state.json.

**post-edit-check.sh** - Monitors writes to Machine/Rules/, suggests /brain-vault-align if active-rules changed.

Then create or merge `.claude/settings.json` with hook configuration pointing to `.brain/hooks/` scripts.

Make all hook scripts executable with `chmod +x`.

## Step 10: Summary

Output a clear summary showing:
- What was created
- Which agents were configured
- Available commands (/brain-today, /brain-new, /brain-tldr, /brain-debrief, /brain-vault-audit, /brain-vault-align, /brain-reflect, /brain-ingest)
- Quick start instructions

</protocol>

<rules>
- NEVER overwrite existing files - skip and report
- ALWAYS use ISO dates (YYYY-MM-DD)
- ALWAYS make hook scripts executable
- If Obsidian format: use [[wikilinks]] and YAML frontmatter
- If plain format: use standard markdown links, no frontmatter requirement
- Keep CLAUDE.md focused on rules only - no data, no session logs
- Create a git commit after setup if the directory is a git repo
</rules>

<success_criteria>
- .brain/ directory exists with state.json and brain.yaml
- Human/ and Machine/ directories exist with all subdirectories
- All 4 memory files exist in Machine/Memory/
- active-rules.md exists in Machine/Rules/
- At least one agent config file generated (CLAUDE.md, .cursorrules, etc.)
- Templates exist in Machine/Templates/
- Hook scripts are executable (if Claude Code selected)
- User sees clear summary with next steps
</success_criteria>
