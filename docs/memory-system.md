# Memory System

## Overview

The AI Brain gives stateless AI agents persistent memory through structured markdown files.

## Memory Files

All memory lives in `Machine/Memory/` inside your vault.

### entities.md
Stores known people, projects, tools, and preferences.

```markdown
## People
- **Alice** (2026-03-28) - Tech lead, prefers async communication
- **Bob** (2026-03-25) - Designer, works EST timezone

## Projects
- **the-ai-brain** (2026-03-28) - Universal AI brain plugin, active

## Tools
- **PostgreSQL** (2026-03-20) - Primary database for all projects

## Preferences
- **Code style** (2026-03-20) - Functional Python, minimal classes
- **Tone** (2026-03-18) - Direct and concise, no filler
```

### decisions.md
Records architectural and workflow decisions with rationale.

```markdown
## 2026-03-28 - Use shell scripts for generators
**Decision:** Use bash + sed for template generation, not Python/Node.
**Rationale:** Zero runtime dependencies. Installable anywhere.
**Revisit if:** Template complexity exceeds sed capabilities.

## 2026-03-25 - Separate Human/ and Machine/ directories
**Decision:** Hard boundary between human and AI content.
**Rationale:** Prevents AI-generated text from contaminating authentic notes.
```

### corrections.md
Every time the user corrects the AI's behavior.

```markdown
## 2026-03-28 14:30
**Correction:** "Don't add emoji to file names"
**Context:** AI created a file called "🧠 brain-setup.md"
**Rule derived:** File names must be plain text, no emoji
**Status:** Added to active-rules.md

## 2026-03-27 09:15
**Correction:** "Use wikilinks, not markdown links"
**Context:** AI used [link](path) instead of [[link]]
**Rule derived:** Always use [[wikilinks]] for internal references
**Status:** Added to active-rules.md
```

### context-cache.md
Frequently referenced context that the AI pre-loads each session.

```markdown
## Active Focus
Currently working on: the-ai-brain project
Sprint goal: Complete install.sh and core skills

## Quick Reference
- Vault path: /home/user/my-vault
- Primary language: Python
- Git remote: github.com/user/project

## Recent Context
Last session worked on generator scripts.
Next priority: testing install flow end-to-end.
```

## Session Logs

Session logs live in `Machine/Session-Logs/` and follow this format:

```markdown
---
date: 2026-03-28
duration: ~45 minutes
agent: claude-code
---

# Session Log - 2026-03-28 14:30

## Summary
Built the generator scripts and tested template substitution.

## Decisions Made
- Use envsubst over sed for template processing
- Keep brain.yaml flat (no deep nesting)

## Files Modified
- generators/generate-claude.sh (new)
- generators/templates/CLAUDE.md.tmpl (updated)

## Open Questions
- Should we support custom template directories?

## Corrections Received
- None this session

## Next Steps
- [ ] Test full install flow
- [ ] Write /today skill
```

## How Memory Compounds

```
Week 1:  Basic rules, few entities, sparse corrections
Week 4:  Rich entity map, clear preferences, tuned rules
Month 3: Deep project history, accurate behavioral model
Month 6: AI knows your patterns better than you do
```

The key is consistency. Every session that writes back makes the next session smarter.
