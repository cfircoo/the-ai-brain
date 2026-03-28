---
name: brain-new
description: Universal brain-dump triage - accepts raw input and routes to correct files. Use when the user says "new", "brain dump", "capture this", "quick note", "log this", "add task", "idea", or pastes unstructured text to be processed into the vault.
---

<objective>
Accept raw, unstructured input (mixed tasks, notes, logs, ideas, references) and intelligently triage each item into the correct vault location with proper formatting, frontmatter, tags, and wikilinks.
</objective>

<protocol>

## Step 1: Accept Input

If the user provided text alongside the command, use that as the input.
If no text was provided, prompt: "What do you want to capture? Paste or type anything -- tasks, notes, ideas, logs, all mixed together is fine."

## Step 2: Load Vault Context

Silently read:
- `Machine/Memory/context-cache.md` -- to understand current projects and context
- `Machine/Memory/entities.md` -- to identify known entities for wikilinks
- `Machine/Rules/active-rules.md` -- for any routing rules

## Step 3: Parse and Classify

Analyze the raw input and break it into distinct items. For each item, classify its type:

| Type | Indicators | Destination |
|------|-----------|-------------|
| **Task** | Action verbs, "need to", "TODO", "should", deadlines | Today's daily note (`Human/Daily/{today}.md`) under `## Tasks` |
| **Note** | Observations, thoughts, facts, context | `Human/` -- new note file or append to existing relevant note |
| **Project idea** | New project concept, feature idea, "we should build" | `Human/Projects/` as a new project note |
| **Decision** | "Decided to", "going with", choice between options | `Machine/Memory/decisions.md` |
| **Entity info** | Facts about a person, tool, project, org | `Machine/Memory/entities.md` |
| **Meeting/event note** | "Met with", "call about", timestamps | `Human/Daily/{today}.md` under `## Notes` |
| **Log/status update** | Progress report, "done with", "finished" | Today's daily note under `## Notes` |
| **Idea/someday** | "Maybe", "someday", "it would be cool if" | `Human/Projects/ideas.md` or `Human/Archive/someday.md` |
| **Correction** | "Don't do X", "always do Y", behavioral instruction | `Machine/Memory/corrections.md` |
| **Reference/link** | URLs, book titles, article references | `Human/` as a reference note with source metadata |

## Step 4: Route Each Item

For each classified item:

1. **Determine the destination file** based on type and context.
2. **Check if the destination file exists.** If yes, append. If no, create with proper frontmatter.
3. **Apply formatting:**
   - YAML frontmatter on new files: `date`, `tags`, `type`
   - `[[wikilinks]]` for any references to known entities or existing notes
   - Proper markdown structure (headers, lists, checkboxes for tasks)
   - Tags based on content (e.g., `#project/name`, `#meeting`, `#idea`)
4. **Write the item** to the destination.

## Step 5: Update Daily Note Log

Append a processing log to today's daily note under a `## Captured` section:

```markdown
## Captured
<!-- Auto-logged by new skill at HH:MM -->
- [task] "Fix the login bug" --> added to Tasks
- [note] "API rate limits are 100/min" --> created [[API Rate Limits]]
- [idea] "Build a CLI dashboard" --> added to [[Ideas]]
- [decision] "Using PostgreSQL over SQLite" --> logged to decisions.md
```

## Step 6: Confirm to User

Present a summary of what was processed:

```
Processed {N} items from your brain dump:

- 2 tasks --> added to today's daily note
- 1 project idea --> created [[Project Name]]
- 1 decision --> logged to decisions.md
- 1 entity update --> updated [[Entity Name]] in entities.md

Anything I miscategorized or missed?
```

</protocol>

<rules>
- Always ask for clarification if an item is ambiguous between two types.
- Never silently discard input -- every piece of text must be routed somewhere.
- Use `[[wikilinks]]` for cross-references to existing vault notes and entities.
- When creating new files in `Human/`, use descriptive filenames in kebab-case (e.g., `api-rate-limits.md`).
- Tasks always get checkboxes (`- [ ]`).
- Respect directory permissions: freely write to `Machine/`, ask before creating new top-level files in `Human/`.
- If the input is a single clear item, skip the classification display and just route it directly.
- Frontmatter is mandatory on every new file created.
</rules>

<success_criteria>
- All items from the input are classified and routed
- Each item lands in the correct vault location
- Proper frontmatter, tags, and wikilinks are applied
- Today's daily note has a log of what was processed
- User receives a clear summary of routing decisions
- No input is silently dropped
</success_criteria>
