# Memory Schema

> Defines the structure, purpose, and conventions for every memory file in
> `Machine/Memory/`. All agents MUST follow these schemas when reading or writing
> memory files.

---

## Overview

The memory system is divided into four files, each serving a distinct purpose:

| File | Purpose | Update Frequency |
|------|---------|-----------------|
| `entities.md` | People, projects, tools, organizations | When a new entity is mentioned or updated |
| `decisions.md` | Significant decisions with rationale | When a meaningful choice is made |
| `corrections.md` | Behavioral corrections from the user | Immediately when corrected |
| `context-cache.md` | Active working memory / current state | Every session, often mid-session |

---

## entities.md

Tracks named entities the user works with or references frequently.

### Schema

Each entity is an H3 heading followed by key-value metadata and optional notes.

```markdown
### {Entity Name}

- **Type:** person | project | tool | organization | concept | other
- **First Mentioned:** YYYY-MM-DD
- **Last Updated:** YYYY-MM-DD
- **Tags:** #tag1 #tag2
- **Summary:** One-line description.

Optional free-text notes, context, or relationships.
Links to related entities: [[Other Entity]]
```

### Rules

- One H3 section per entity. No duplicates.
- When an entity is mentioned again with new information, update the existing entry
  (change `Last Updated`, append to notes).
- Keep summaries to one line. Put detail in the notes section.
- Use wikilinks to cross-reference entities when relevant.

---

## decisions.md

Tracks significant decisions and their rationale so they can be recalled later.

### Schema

Each decision is an H3 heading with structured fields.

```markdown
### {Short Decision Title}

- **Date:** YYYY-MM-DD
- **Context:** Brief description of the situation or question.
- **Decision:** What was decided.
- **Rationale:** Why this was chosen over alternatives.
- **Alternatives Considered:** What else was considered (if any).
- **Status:** active | superseded | revisit
- **Related:** [[entity]] or [[file]] links
```

### Rules

- Record decisions that affect future behavior, architecture, workflow, or preferences.
- Do NOT record trivial choices (e.g., "user asked me to use bullet points this one time").
- When a decision is reversed, mark the old entry as `superseded` and link to the new one.
- Decisions should be concise. If extensive analysis was done, link to the session log.

---

## corrections.md

Tracks behavioral corrections from the user -- things the agent did wrong and the
correct behavior going forward.

### Schema

Each correction is an H3 heading with structured fields.

```markdown
### {Short Description of Correction}

- **Date:** YYYY-MM-DD
- **What I Did Wrong:** Description of the incorrect behavior.
- **Correct Behavior:** What I should do instead.
- **Promoted to Rule:** yes | no | pending
- **Rule Reference:** [[active-rules.md#rule-name]] (if promoted)
```

### Rules

- Every correction gets logged here, even minor ones.
- If a correction is promoted to a rule (user approves), set `Promoted to Rule: yes`
  and link to the rule.
- Corrections are append-only. Never delete a correction even if it is later superseded.
- Group related corrections if they address the same underlying issue.

---

## context-cache.md

The agent's "working memory." Contains the current state of what is being worked on.
Unlike other memory files, this one is meant to be **rewritten frequently** rather than
appended to.

### Schema

```markdown
---
date: YYYY-MM-DD
type: memory
last_updated: YYYY-MM-DDTHH:mm
---

# Context Cache

## Current Focus
What the user is actively working on right now.

## Active Projects
- [[Project 1]] - status / next step
- [[Project 2]] - status / next step

## Recent Decisions
- Decision summary (YYYY-MM-DD) -- link to decisions.md entry

## Pending / Open Items
- Unresolved questions
- Items the user said they'd come back to
- Promises or commitments made

## Key Files
- Paths to files that are currently relevant
```

### Rules

- Keep this file **short and scannable** -- aim for under 40 lines.
- Overwrite sections rather than appending endlessly.
- Update at least once per session (during or at end).
- This is the first memory file an agent reads on startup, so clarity is paramount.
- Remove items that are no longer active. Old context belongs in session logs.
