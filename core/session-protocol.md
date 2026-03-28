# Session Protocol

> Detailed specification of the read-on-start and write-on-end protocol that every
> agent MUST follow. This expands on the summary in `brain-rules.md`.

---

## Session Start: Read Phase

When a new session begins, the agent performs the following reads **before** doing
any user-requested work. This entire phase should be silent -- do not narrate each
file read to the user.

### Step 1: Load Rules

**File:** `Machine/Rules/active-rules.md`

Read the full contents. These are the user-approved behavioral rules that override
any default behavior. Treat every rule as a hard constraint unless the user explicitly
says otherwise during the session.

If the file does not exist or is empty, fall back to the defaults in `core/brain-rules.md`.

### Step 2: Load Context Cache

**File:** `Machine/Memory/context-cache.md`

Read the full contents. This tells you:
- What the user was last working on
- Active projects and their status
- Pending items and open questions
- Recently relevant files

Use this to orient yourself. If the user starts talking without context, you should
already know what they are likely referring to.

### Step 3: Load Recent Session Logs

**Directory:** `Machine/Session-Logs/`

Read the most recent session log(s), up to the `memory.max_recent_logs` value in
`brain.yaml` (default: 3). Sort by filename (which uses `YYYY-MM-DD-HHmm` format)
in descending order.

These logs provide:
- Continuity with recent conversations
- Decisions that were made
- Open questions that may still be relevant
- Corrections that were given

### Step 4: Load Today's Daily Note

**File:** `Human/Daily/{YYYY-MM-DD}.md` (using today's date)

If it exists, read it. The daily note may contain:
- The user's priorities for the day
- Notes or thoughts they jotted down
- Tasks or reminders

If it does not exist, skip silently. Do NOT create it unless the user asks.

### Step 5: Load Entities and Corrections (Optional)

If the session is likely to involve references to known entities or past corrections,
optionally scan:
- `Machine/Memory/entities.md` for key entities
- `Machine/Memory/corrections.md` for recent corrections

This step is at the agent's discretion based on available context window.

### After Startup

Once all reads are complete, the agent may:
- Greet the user
- Reference recent context naturally (e.g., "Last time we were working on X...")
- Ask about open items from the context cache

Do NOT dump a summary of everything you read. Be natural.

---

## Session End: Write Phase

Before the session ends, the agent writes a session log and updates memory files.

### Step 1: Write Session Log

**Directory:** `Machine/Session-Logs/`
**Filename:** `YYYY-MM-DD-HHmm.md` (use the session start time or current time)

Use the template at `Machine/Templates/session-log.md`. Include:

| Section | Content |
|---------|---------|
| Date | ISO date of the session |
| Duration | Approximate length (e.g., "~30 minutes") |
| Summary | 2-5 sentences on what happened |
| Key Decisions | Bulleted list of decisions with brief rationale |
| Files Changed | List of file paths that were created, modified, or deleted |
| Corrections | Any behavioral corrections received |
| Open Items | Questions, next steps, or deferred tasks |
| Mood/Tone | Optional: note the user's apparent mood or energy if relevant |

### Step 2: Update Context Cache

**File:** `Machine/Memory/context-cache.md`

Rewrite the context cache to reflect the current state:
- Update "Current Focus" to whatever the user is now working on
- Update "Active Projects" with any status changes
- Add new "Recent Decisions"
- Update "Pending / Open Items" -- add new ones, remove resolved ones
- Update "Key Files" with currently relevant paths

### Step 3: Update Entity Memory

**File:** `Machine/Memory/entities.md`

If any new entities were mentioned or existing entities gained new information,
update the file. See `memory-schema.md` for the entity format.

### Step 4: Update Decision Log

**File:** `Machine/Memory/decisions.md`

If any significant decisions were made during the session, log them.
See `memory-schema.md` for the decision format.

### Step 5: Update Corrections

**File:** `Machine/Memory/corrections.md`

If any corrections were received, they should already be logged (corrections are
logged immediately, not deferred to session end). Verify they are present.

---

## Edge Cases

### Short Sessions

If a session is very short (e.g., a quick question with no significant decisions),
the agent may skip the session log write if there is truly nothing meaningful to record.
Still update the context cache if anything changed.

### Interrupted Sessions

If a session ends abruptly (user closes the window, connection drops), the agent
should write whatever it can on the next startup. Include a note that the previous
session ended unexpectedly.

### Multiple Sessions Per Day

Use the `HHmm` suffix in session log filenames to distinguish multiple sessions on
the same day. Each session gets its own log file.

### First Session Ever

On the very first session (no session logs exist, memory files are empty templates):
- Skip startup reads gracefully
- Focus on learning about the user
- Write an especially thorough first session log
- Populate entities and context cache based on the conversation
