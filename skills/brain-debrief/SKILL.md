---
name: brain-debrief
description: End-of-session ritual - writes session log, updates memory, flags carryovers. Use when the user says "debrief", "end session", "wrap up", "save session", "closing time", "done for now", "shutting down", or is about to end a session.
---

<objective>
Perform a complete end-of-session ritual: summarize accomplishments, write a structured session log, update all memory files, identify incomplete tasks for carryover, and update vault state. This ensures full continuity for the next session.
</objective>

<protocol>

## Step 1: Analyze the Session

Review the entire current conversation and identify:

- **Accomplishments:** What was done (files created, decisions made, problems solved)
- **Decisions:** Significant choices with rationale
- **Corrections:** Any behavioral corrections received from the user
- **Files changed:** List of all files created, modified, or deleted
- **Open items:** Unfinished tasks, unanswered questions, deferred work
- **Context state:** What the user is currently working on, active projects

## Step 2: Write Session Log

Create a new file at `Machine/Session-Logs/{YYYY-MM-DD-HHmm}.md` using the current timestamp.

Structure:

```markdown
---
date: YYYY-MM-DD
tags: [session-log]
type: session-log
duration: ~{estimate}
---

# Session Log: {YYYY-MM-DD HH:MM}

## Summary
{2-5 sentences describing what happened in this session}

## Accomplishments
- {what was completed}

## Decisions Made
- **{decision title}:** {what was decided} -- {rationale}

## Files Changed
- `{path}` -- {what changed}

## Corrections Received
- {correction description} (or "None")

## Open Items
- [ ] {task or question to carry forward}

## Next Session
{suggested starting point for the next session}
```

## Step 3: Update Context Cache

Rewrite `Machine/Memory/context-cache.md` to reflect the post-session state:

- **Current Focus:** Update to whatever the user is now working on
- **Active Projects:** Update status of any projects discussed
- **Recent Decisions:** Add decisions from this session
- **Pending / Open Items:** Add new open items, remove any that were resolved
- **Key Files:** Update with currently relevant file paths

Keep the file under 40 lines. Remove stale information.

## Step 4: Update Entity Memory

If any new entities were mentioned or existing entities gained new information during the session, update `Machine/Memory/entities.md` following the schema in `core/memory-schema.md`.

## Step 5: Update Decision Log

If significant decisions were made, append them to `Machine/Memory/decisions.md` following the schema in `core/memory-schema.md`.

## Step 6: Update Corrections

Verify that any corrections received during the session are logged in `Machine/Memory/corrections.md`. Corrections should have been logged in real-time, but confirm completeness.

## Step 7: Update State File

Update `.brain/state.json` with:

```json
{
  "last_session": "YYYY-MM-DDTHH:MM",
  "sessions_count": {increment},
  "last_session_log": "Machine/Session-Logs/{filename}.md",
  "open_items_count": {count of open items},
  "active_projects": ["project1", "project2"]
}
```

Create the `.brain/` directory and `state.json` if they do not exist.

## Step 8: Update Today's Daily Note

Append a session summary to `Human/Daily/{today}.md` under a `## Sessions` section:

```markdown
## Sessions

### {HH:MM} Session
- {1-2 line summary}
- Key: {most important outcome}
- Open: {most important open item}
```

If the daily note does not exist, create it first with standard frontmatter.

## Step 9: Confirm to User

Present a brief debrief summary:

```
Session wrapped up. Here is what was saved:

Session log: Machine/Session-Logs/{filename}.md
Duration: ~{estimate}

Accomplished:
- {key accomplishments}

Carrying forward:
- {open items for next session}

Memory updated: context-cache, {entities if updated}, {decisions if updated}

See you next time!
```

</protocol>

<rules>
- Always write the session log, even for short sessions. The only exception is if truly nothing happened.
- Context cache must be rewritten (not appended to) -- it reflects current state only.
- Session logs are append-only. Never modify a previous session log.
- Open items must use checkbox format (`- [ ]`) so they can be tracked.
- If `.brain/state.json` does not exist, create it with initial values.
- Use `[[wikilinks]]` in session logs and daily notes.
- Keep the user-facing summary brief. The detailed record is in the log file.
- If corrections were received, confirm they are recorded and mention any pending rule proposals.
</rules>

<success_criteria>
- Session log written to `Machine/Session-Logs/` with complete structure
- `Machine/Memory/context-cache.md` reflects current state
- Entity, decision, and correction memory files updated as needed
- `.brain/state.json` updated with session metadata
- Today's daily note includes a session summary
- Open items are clearly identified for carryover
- User receives a concise debrief confirmation
</success_criteria>
