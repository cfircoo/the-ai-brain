# Commands Reference

All commands are available as Claude Code slash commands when the brain is installed.

## Daily Workflow

### /today
Morning startup planner. Loads yesterday's context, scans for overdue items, generates a prioritized daily plan.

```
/today
```

### /new
Universal brain-dump triage. Accepts any raw text and routes items to correct files.

```
/new Had 3 meetings today. Need to follow up with Alice about the API.
Ate a sandwich for lunch. New idea: build a CLI dashboard.
```

### /debrief
End-of-session ritual. Writes session log, updates memory, flags incomplete tasks.

```
/debrief
```

### /tldr
Summarize current session, a file, or a topic.

```
/tldr                          # Summarize this session
/tldr Machine/Session-Logs/    # Summarize recent sessions
/tldr "project alpha"          # Summarize a topic
```

## Vault Management

### /vault-audit
Health check. Reports on vault statistics, orphaned files, stale content, tag usage.

```
/vault-audit
```

### /vault-align
Re-sync agent configs from brain.yaml and active-rules. Run after editing brain.yaml.

```
/vault-align
```

## Intelligence

### /reflect
AI self-review. Analyzes recent sessions and corrections, proposes rule improvements.

```
/reflect              # Default: last 7 days
/reflect 30 days      # Last 30 days
```

### /ingest
Import external content with proper formatting and categorization.

```
/ingest /path/to/document.pdf
/ingest "paste raw text here"
```
