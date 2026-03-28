---
name: brain-vault-align
model: claude-sonnet-4-6
context: forked
description: Re-sync all agent configs from brain.yaml and active-rules. Use when the user says "vault align", "sync configs", "regenerate configs", "update rules", "re-sync", "align vault", or when agent config files need to be regenerated after rule or structure changes.
---

<objective>
Audit the alignment between brain.yaml, active-rules.md, and actual vault conventions. Detect drift, propose updates to active-rules.md, and regenerate all enabled agent configuration files (CLAUDE.md, .cursorrules, GEMINI.md, AGENTS.md) from the current rules and templates.
</objective>

<protocol>

## Step 1: Load Source of Truth

Read the following files:

1. `brain.yaml` -- master configuration
2. `Machine/Rules/active-rules.md` -- current behavioral rules
3. `core/brain-rules.md` -- universal base rules

## Step 2: Scan Vault Conventions

Analyze actual vault usage patterns to detect conventions:

1. **Frontmatter patterns:** Sample 10-20 recent files. What fields are consistently used? Any new fields not in the standard schema?
2. **Tag patterns:** What tags are actively used? Any new tag namespaces (e.g., `#project/name`)?
3. **File naming patterns:** Are files using kebab-case, camelCase, spaces? Is it consistent?
4. **Wikilink patterns:** How are wikilinks used? Short names vs full paths?
5. **Directory usage:** Are files landing in the expected directories per brain.yaml?

## Step 3: Detect Drift

Compare active-rules.md against actual vault conventions:

### Rules without matching reality
Rules in active-rules.md that do not match actual vault behavior:
- A rule says "use kebab-case" but recent files use spaces
- A rule references a directory that does not exist
- A rule describes a process that session logs show is not followed

### Reality without matching rules
Conventions observed in the vault that are not captured in active-rules.md:
- Consistent patterns in recent files not documented as rules
- New directories or structures that emerged organically
- Behavioral corrections in `Machine/Memory/corrections.md` not yet promoted to rules

### Configuration drift
Differences between brain.yaml settings and actual practice:
- `preferences.wikilinks: true` but files do not use wikilinks
- `memory.session_logs: true` but no session logs exist
- Agents marked `enabled: true` but config files are missing or outdated

## Step 4: Propose Rule Updates

Present a summary of drift findings and propose specific changes:

```
## Drift Report

### Rules to Update
1. Rule "{name}" -- actual practice differs: {description}
   Proposed: {updated rule text}

### Rules to Add
1. New rule: "{name}" -- observed pattern: {description}
   Proposed: {rule text}

### Rules to Remove
1. Rule "{name}" -- no longer applicable: {reason}

### No Changes Needed
{list rules that are aligned}
```

Ask for user approval before making any changes to active-rules.md.

## Step 5: Update Active Rules (with approval)

If the user approves changes:

1. Update `Machine/Rules/active-rules.md` with approved changes.
2. Append entries to `Machine/Rules/rule-changelog.md`:
   ```markdown
   ### {YYYY-MM-DD} -- Vault Alignment
   - Updated: {rule name} -- {reason}
   - Added: {rule name} -- {reason}
   - Removed: {rule name} -- {reason}
   ```

## Step 6: Regenerate Agent Configs

For each agent marked `enabled: true` in brain.yaml:

1. Read the corresponding template from `generators/templates/`:
   - Claude Code: `CLAUDE.md.tmpl`
   - Cursor: `cursorrules.tmpl`
   - Gemini CLI: `gemini.md.tmpl`
   - Codex: `codex.md.tmpl`

2. Regenerate the config file by combining:
   - Base rules from `core/brain-rules.md`
   - Active rules from `Machine/Rules/active-rules.md`
   - Owner profile from brain.yaml
   - Vault structure from brain.yaml
   - Agent-specific adaptations from the template

3. Write the regenerated config to the location specified in brain.yaml (`agents.{name}.config_file`).

4. If skills are enabled for an agent (`agents.{name}.skills: true`), ensure skill references are included in the config.

## Step 7: Report Results

```
## Vault Alignment Complete

### Rules Updated
- {N} rules modified, {N} added, {N} removed
- Changelog updated: Machine/Rules/rule-changelog.md

### Configs Regenerated
- CLAUDE.md -- regenerated (Claude Code)
- .cursorrules -- regenerated (Cursor)
- {or "skipped -- agent not enabled"}

### Remaining Drift
- {any drift the user chose not to address}
- {or "Vault is fully aligned."}
```

</protocol>

<rules>
- Never modify active-rules.md without explicit user approval.
- Always show proposed changes before applying them.
- Regenerated configs should be complete replacements, not patches.
- If a template file is missing for an enabled agent, warn the user rather than generating a config from scratch.
- Log all changes to rule-changelog.md for auditability.
- If brain.yaml has no agents enabled, skip config regeneration and inform the user.
- Preserve any manually-added sections in agent configs by checking for `<!-- custom -->` markers.
</rules>

<success_criteria>
- Drift between rules and reality is identified
- Proposed rule updates are presented clearly
- Active-rules.md updated only with user approval
- Rule changelog is maintained
- All enabled agent configs are regenerated from current rules
- Report shows what was updated and any remaining drift
</success_criteria>
