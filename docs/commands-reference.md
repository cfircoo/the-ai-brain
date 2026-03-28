# Commands Reference

All commands are available as Claude Code slash commands when the brain is installed.

## Daily Workflow

### /brain-today
Morning startup planner. Loads yesterday's context, scans for overdue items, generates a prioritized daily plan.

```
/brain-today
```

### /brain-new
Universal brain-dump triage. Accepts any raw text and routes items to correct files.

```
/brain-new Had 3 meetings today. Need to follow up with Alice about the API.
Ate a sandwich for lunch. New idea: build a CLI dashboard.
```

### /brain-debrief
End-of-session ritual. Writes session log, updates memory, flags incomplete tasks.

```
/brain-debrief
```

### /brain-tldr
Summarize current session, a file, or a topic.

```
/brain-tldr                          # Summarize this session
/brain-tldr Machine/Session-Logs/    # Summarize recent sessions
/brain-tldr "project alpha"          # Summarize a topic
```

## Vault Management

### /brain-vault-audit
Health check. Reports on vault statistics, orphaned files, stale content, tag usage.

```
/brain-vault-audit
```

### /brain-vault-align
Re-sync agent configs from brain.yaml and active-rules. Run after editing brain.yaml.

```
/brain-vault-align
```

## Intelligence

### /brain-reflect
AI self-review. Analyzes recent sessions and corrections, proposes rule improvements.

```
/brain-reflect              # Default: last 7 days
/brain-reflect 30 days      # Last 30 days
```

### /brain-ingest
Import external content with proper formatting and categorization.

```
/brain-ingest /path/to/document.pdf
/brain-ingest "paste raw text here"
```
