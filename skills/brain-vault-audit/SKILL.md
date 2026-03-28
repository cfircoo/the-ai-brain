---
name: brain-vault-audit
description: Health check - counts notes, finds orphans, checks consistency. Use when the user says "vault audit", "health check", "check vault", "find orphans", "vault stats", "audit", or wants to understand the state of their vault.
---

<objective>
Perform a comprehensive health check of the vault: count files, find orphaned notes, check frontmatter consistency, identify stale content, analyze tag usage, and verify vault structure against brain.yaml. Output a formatted health report.
</objective>

<protocol>

## Step 1: Load Vault Configuration

Read `brain.yaml` to get the expected vault structure:
- `vault.structure.*` for expected directories
- `preferences.frontmatter` for whether frontmatter is expected
- `preferences.wikilinks` for whether wikilinks are expected
- `preferences.format` for format type (obsidian/plain)

## Step 2: File Census

Count total `.md` files in each top-level directory and subdirectory:

```
Human/
  Daily/        -- {count} files
  Projects/     -- {count} files
  Archive/      -- {count} files
  (other)/      -- {count} files
Machine/
  Session-Logs/ -- {count} files
  Memory/       -- {count} files
  Rules/        -- {count} files
  Templates/    -- {count} files
  (other)/      -- {count} files
Total:          -- {count} files
```

Also note any directories that exist but are not defined in `brain.yaml`.

## Step 3: Orphan Detection

**If Obsidian CLI is available** (run `obsidian version` to check), use the built-in orphan command:
```bash
obsidian orphans format=json
```
This returns a JSON array of file paths with zero incoming links. Parse and display grouped by directory.

**If Obsidian CLI is not available**, fall back to the manual approach below:

An orphaned file is one that has no incoming `[[wikilinks]]` from any other file in the vault.

1. Build a list of all `.md` files in the vault.
2. For each file, extract its basename (without extension) as its "link name."
3. Search all other files for `[[link name]]` references.
4. A file is orphaned if no other file links to it.

**Exceptions (not orphans):**
- Daily notes (`Human/Daily/`) -- these are date-indexed, not link-indexed
- Session logs (`Machine/Session-Logs/`) -- these are date-indexed
- Root config files (`brain.yaml`, `CLAUDE.md`, etc.)
- Template files (`Machine/Templates/`)
- Memory files (`Machine/Memory/`) -- these are system files
- Rules files (`Machine/Rules/`) -- these are system files

Report orphans grouped by directory.

## Step 4: Frontmatter Consistency

For every `.md` file that should have frontmatter (per `preferences.frontmatter`):

1. Check if YAML frontmatter exists (file starts with `---`).
2. Check for required fields: `date`, `tags`, `type`.
3. Check date format matches `preferences.date_format`.

Report:
- Files missing frontmatter entirely
- Files with incomplete frontmatter (missing required fields)
- Files with malformed dates

## Step 5: Stale File Detection

Identify files not modified in 90+ days:

1. Check file modification times for all `.md` files.
2. Flag files older than 90 days.

**Exceptions:**
- Template files (expected to be stable)
- Rules files (expected to be stable unless updated)
- `brain.yaml` (configuration, not content)

Group stale files by directory and sort by age (oldest first).

## Step 6: Tag Analysis

Scan all files for tags (both YAML frontmatter `tags:` and inline `#tag` format):

1. Build a frequency map of all tags.
2. Identify tags used fewer than 3 times ("low-usage tags").
3. Identify the most common tags (top 10).
4. Flag any tags that look like typos (similar to other tags, e.g., `#proejct` vs `#project`).

## Step 7: Structure Validation

Compare the actual vault directory structure against `brain.yaml` `vault.structure`:

- **Missing directories:** Defined in config but do not exist
- **Extra directories:** Exist but not defined in config
- **Empty directories:** Exist but contain no files

## Step 8: Generate Health Report

Output a formatted report:

```markdown
# Vault Health Report
**Date:** {YYYY-MM-DD}
**Vault:** {vault path from brain.yaml}

## File Census
| Directory | Files | Notes |
|-----------|-------|-------|
| Human/Daily | {N} | |
| Human/Projects | {N} | |
| ... | | |
| **Total** | **{N}** | |

## Orphaned Files ({count})
{list of orphaned files, grouped by directory}
{or "No orphans found."}

## Frontmatter Issues ({count})
- `{path}` -- {issue description}
{or "All files have valid frontmatter."}

## Stale Files ({count}, >90 days)
- `{path}` -- last modified {date} ({N} days ago)
{or "No stale files found."}

## Tag Analysis
**Total unique tags:** {N}
**Most used:** {tag} ({N}), {tag} ({N}), ...
**Low usage (<3):** {tag} ({N}), {tag} ({N}), ...
**Possible typos:** {tag} -- did you mean {similar tag}?

## Structure Validation
- Missing directories: {list or "None"}
- Extra directories: {list or "None"}
- Empty directories: {list or "None"}

## Overall Health: {Good | Fair | Needs Attention}
{1-2 sentence summary of vault health}
```

## Step 9: Offer Actions

After presenting the report, offer actionable suggestions:

- "Fix frontmatter on {N} files?"
- "Create missing directories?"
- "Review orphaned files for linking or archiving?"
- "Clean up stale files?"

Wait for user direction before taking any action.

</protocol>

<rules>
- This is a read-only operation. Do NOT modify any files unless the user explicitly asks.
- Report findings factually without judgment -- the user decides what to fix.
- Daily notes and session logs are exempt from orphan detection.
- Memory and rules files are exempt from orphan detection.
- Be efficient with file reads -- use glob patterns and grep rather than reading every file in full.
- If the vault is very large (500+ files), warn the user that the audit may take a moment.
- Save the report to `Machine/vault-audit-{YYYY-MM-DD}.md` only if the user asks.
</rules>

<success_criteria>
- Accurate file counts by directory
- Orphaned files correctly identified (with proper exemptions)
- Frontmatter consistency checked on all applicable files
- Stale files identified with modification dates
- Tag analysis with frequency data
- Structure validated against brain.yaml
- Clean, readable health report presented
- Actionable suggestions offered without auto-executing
</success_criteria>
