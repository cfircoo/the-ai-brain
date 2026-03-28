---
name: brain-today
description: Morning startup - loads context, shows today's plan, flags overdue items. Use when starting the day, wanting a daily plan, or saying "good morning", "what's on today", "daily plan", "start the day".
---

<objective>
Perform a full morning startup ritual: load all vault context, create today's daily note if missing, identify carryover tasks from yesterday, flag overdue "eat the frog" items, and output a prioritized daily plan.
</objective>

<protocol>

## Step 1: Determine Dates

Calculate today's date and yesterday's date in `YYYY-MM-DD` format. These are used for daily note paths and session log lookups.

## Step 2: Read Vault Context

Read the following files silently (skip any that do not exist):

1. `Machine/Rules/active-rules.md` -- behavioral rules
2. `Machine/Memory/context-cache.md` -- current working memory
3. `Machine/Memory/entities.md` -- known entities
4. `Machine/Memory/decisions.md` -- recent decisions

## Step 3: Read Recent Session Logs

Scan `Machine/Session-Logs/` for the 3 most recent log files (sorted by filename descending). Read each one. Extract:

- What was accomplished
- Open items and next steps
- Corrections received
- Unresolved questions

## Step 4: Read Yesterday's Daily Note

Read `Human/Daily/{yesterday}.md` if it exists. Identify:

- Tasks marked incomplete (unchecked `- [ ]` items)
- Notes or priorities that should carry over
- Anything explicitly flagged for "tomorrow"

## Step 5: Read or Create Today's Daily Note

Check if `Human/Daily/{today}.md` exists.

**If it exists:** Read it and incorporate the user's existing priorities.

**If it does not exist:** Create it from the daily note template. The template structure:

```markdown
---
date: {YYYY-MM-DD}
tags: [daily]
type: note
---

# {YYYY-MM-DD}

## Priorities
-

## Tasks
- [ ]

## Notes

## Carryover from Yesterday
<!-- Auto-populated by today skill -->
```

Populate the "Carryover from Yesterday" section with any incomplete tasks from yesterday's note.

## Step 6: Eat the Frog Analysis

Scan the last 3-5 daily notes (`Human/Daily/`) for tasks that appear repeatedly without being completed. Any task that has appeared on 3 or more days without being checked off is an "eat the frog" candidate -- a task the user is avoiding.

Flag these prominently in the output.

## Step 7: Output Daily Plan

Present a structured daily plan to the user:

```
Good morning! Here is your plan for {today}.

## Eat the Frog (overdue items)
- {task} -- has appeared on {N} daily notes without completion

## Carryover from Yesterday
- {incomplete tasks from yesterday}

## Today's Priorities
- {from today's daily note or context cache}

## Active Projects
- [[Project]] -- {status from context cache}

## Open Items from Recent Sessions
- {unresolved items from session logs}

## Context
{brief summary of where things left off}
```

Adjust the plan based on what data is available. Omit sections that have no content.

</protocol>

<rules>
- Do NOT narrate each file read. Load context silently, then present the plan.
- Do NOT modify files in `Human/` except to create today's daily note if missing.
- Carryover items should be copied, not moved -- yesterday's note stays intact.
- Use `[[wikilinks]]` for all internal references.
- Keep the output concise and actionable -- this is a quick morning briefing, not a report.
- If the vault is empty (first use), acknowledge it and offer to help set up the day.
</rules>

<success_criteria>
- Today's daily note exists after this skill runs
- Carryover items from yesterday are identified
- Eat-the-frog items (3+ days overdue) are flagged
- User receives a clear, prioritized daily plan
- Context from recent sessions is incorporated
</success_criteria>
