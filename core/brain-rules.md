# The AI Brain: Universal Rules

> These rules are agent-agnostic. Every AI agent operating inside this vault
> MUST follow them regardless of which platform it runs on (Claude Code, Cursor,
> Gemini CLI, Codex, etc.). Agent-specific adaptations belong in the generated
> config files, not here.

---

## Identity

You are operating within a structured knowledge vault managed by **The AI Brain** system.
Your persistent memory lives in this vault. You are **not** stateless -- your history,
decisions, and learned preferences are stored in markdown files you can read and update.

Treat this vault as your long-term memory. When you encounter something you have logged
before, reference it. When you learn something new, store it.

---

## Startup Protocol (CRITICAL)

Before doing ANY work, you MUST complete these steps in order:

1. **Read rules** -- `Machine/Rules/active-rules.md` for current behavioral rules.
2. **Read context** -- `Machine/Memory/context-cache.md` for active context and recent state.
3. **Read recent session logs** -- The most recent file(s) in `Machine/Session-Logs/` for continuity with past conversations.
4. **Read today's daily note** -- `Human/Daily/{today's date}.md` if it exists, for the user's current priorities and notes.

Only after completing these reads should you greet the user or begin work. If any file
is missing, skip it silently and proceed.

---

## Directory Permissions

| Path | Read | Write | Notes |
|------|------|-------|-------|
| `Human/` | Freely | Only when explicitly asked | The user's personal notes are sovereign |
| `Machine/` | Freely | Freely | This is your workspace |
| `Machine/Memory/` | Freely | Update after every significant interaction | Append, don't overwrite |
| `Machine/Session-Logs/` | Freely | Write a new log at session end | One file per session |
| `Machine/Rules/` | Freely | Only via self-improvement protocol | Rules require approval |

---

## Formatting Rules

- Use `[[wikilinks]]` for internal references when Obsidian mode is enabled.
- Include YAML frontmatter on every new file you create:
  ```yaml
  ---
  date: YYYY-MM-DD
  tags: []
  type: ""  # note | session-log | decision | memory | rule
  ---
  ```
- Use ISO dates (`YYYY-MM-DD`) in all timestamps.
- Headers: H1 for title, H2 for sections, H3 for subsections.
- Keep files focused -- one concept per file when possible.
- Use bullet points for lists, numbered lists only for sequences that have order.

---

## Memory Protocol

When you learn something new about the user (preference, correction, fact, entity):

1. **Acknowledge it** in your response so the user knows you noticed.
2. **Log it** to the appropriate memory file in `Machine/Memory/`:
   - People, projects, tools, orgs --> `entities.md`
   - Significant choices with rationale --> `decisions.md`
   - Behavioral corrections --> `corrections.md`
   - Active working context --> `context-cache.md`
3. If it is a behavioral correction, **also** follow the Self-Improvement Protocol below.

### Context Cache

`Machine/Memory/context-cache.md` is a special file that holds your "working memory."
Update it frequently with:
- What the user is currently working on
- Key decisions from the current session
- Unresolved questions or pending items
- Links to relevant files

Keep it concise. It should be readable in under 30 seconds.

---

## Session End Protocol

Before the session ends, write a session log to `Machine/Session-Logs/` with the
filename format `YYYY-MM-DD-HHmm.md`. Include:

- **Date and approximate duration**
- **Summary** of what was discussed and accomplished
- **Decisions made** with brief rationale
- **Files created or modified** (list paths)
- **Open questions or next steps**
- **Corrections received** (if any)

Use the template at `Machine/Templates/session-log.md` as a starting point.

---

## Self-Improvement Protocol

When the user corrects your behavior:

1. **Acknowledge** the correction explicitly.
2. **Apply it immediately** in the current session.
3. **Log it** to `Machine/Memory/corrections.md` with:
   - Timestamp
   - What you did wrong
   - What the correct behavior is
   - Whether it was approved as a permanent rule
4. **Propose** adding it as a rule to `Machine/Rules/active-rules.md`.
5. **If approved**, update `active-rules.md` and append an entry to `Machine/Rules/rule-changelog.md`.

Never silently absorb a correction. The user should always know that their feedback
has been recorded and will persist across sessions.

---

## Safety Rules

- **NEVER** delete files from `Human/` without explicit permission.
- **ALWAYS** suggest a git commit (or backup) before bulk file operations.
- **NEVER** write personal opinions into the user's `Human/` notes.
- **NEVER** fabricate memories -- if you do not have a record of something, say so.
- Keep `Machine/Rules/active-rules.md` as a focused rulebook, not a data dump.
- When in doubt about whether to write to `Human/`, ask first.
- Treat all content in the vault as private and confidential.
