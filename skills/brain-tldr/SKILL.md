---
name: brain-tldr
model: claude-haiku-4-5-20251001
description: Summarize current session, a specific file, or a topic from the vault. Use when the user says "tldr", "summarize", "recap", "what happened", "summary of", "catch me up", or wants a quick overview of something.
---

<objective>
Produce a concise, actionable summary of the current session, a specific file, or a topic by searching the vault. Capture key decisions and next steps. Optionally save session summaries to the session logs.
</objective>

<protocol>

## Step 1: Determine Summary Mode

Based on the user's input, select one of three modes:

| Input | Mode | Action |
|-------|------|--------|
| No argument (just "tldr") | **Session** | Summarize the current conversation |
| A file path (e.g., `Human/Projects/my-project.md`) | **File** | Summarize that specific file |
| A topic (e.g., "the auth migration", "project X") | **Topic** | Search vault and synthesize across files |

## Step 2: Gather Content

### Session Mode

Review the current conversation history. Identify:
- Topics discussed
- Decisions made
- Actions taken (files created/modified)
- Questions raised
- Unresolved items

### File Mode

Read the specified file. If it references other files via `[[wikilinks]]`, optionally read those too for context (up to 3 linked files). Identify:
- Purpose of the file
- Key information it contains
- Current status (if applicable)
- Links to related notes

### Topic Mode

Search the vault for files related to the topic:
1. Search filenames for matches
2. Search file contents for the topic keyword(s)
3. Check `Machine/Memory/entities.md` for a matching entity
4. Check `Machine/Memory/decisions.md` for related decisions
5. Check recent session logs in `Machine/Session-Logs/` for mentions

Collect all relevant files and synthesize.

## Step 3: Generate Summary

Structure the summary based on mode:

### Session Summary Format

```markdown
## Session TLDR

**Duration:** ~{estimate}
**Topics:** {comma-separated list}

### What Happened
- {bullet points of key events}

### Decisions Made
- {decision}: {rationale}

### Next Steps
- [ ] {action item}
- [ ] {action item}

### Open Questions
- {unresolved question}
```

### File Summary Format

```markdown
## TLDR: {filename}

**Type:** {note/project/decision/etc.}
**Last Updated:** {date from frontmatter}

### Key Points
- {main takeaways}

### Related
- [[linked note 1]]
- [[linked note 2]]
```

### Topic Summary Format

```markdown
## TLDR: {topic}

**Sources:** {N} files referenced

### Overview
{synthesized summary across all sources}

### Key Points
- {main points from across files}

### Timeline
- {date}: {event} (from [[source]])

### Current Status
{where things stand now}

### Related Files
- [[file 1]] -- {relevance}
- [[file 2]] -- {relevance}
```

## Step 4: Save (Session Mode Only)

If summarizing a session, offer to save the summary:

"Save this session summary to Machine/Session-Logs/? (y/n)"

If yes, write to `Machine/Session-Logs/{YYYY-MM-DD-HHmm}.md` with proper frontmatter:

```yaml
---
date: YYYY-MM-DD
tags: [session-log]
type: session-log
---
```

</protocol>

<rules>
- Keep summaries concise. The whole point of TLDR is brevity.
- Session summaries should be under 20 lines of content.
- File summaries should be under 15 lines of content.
- Topic summaries can be longer (up to 30 lines) since they synthesize multiple sources.
- Always include "Next Steps" or "Open Questions" if any exist -- these are the most actionable parts.
- Use `[[wikilinks]]` for all vault references.
- Do NOT modify any source files -- this is a read-only operation (except saving session logs).
- If a file or topic cannot be found, say so clearly rather than guessing.
</rules>

<success_criteria>
- Summary is concise and captures the essential information
- Key decisions and next steps are highlighted
- Sources are properly attributed with wikilinks
- Session summaries can be saved to session logs
- No source files are modified
</success_criteria>
