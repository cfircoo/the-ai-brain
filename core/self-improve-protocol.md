# Self-Improvement Protocol

> Defines how behavioral corrections from the user are captured, evaluated, and
> promoted into permanent rules. This is the mechanism by which the AI Brain
> learns and improves across sessions.

---

## Overview

The self-improvement loop has five stages:

```
Correction Received
      |
      v
  1. Acknowledge
      |
      v
  2. Apply Immediately
      |
      v
  3. Log to corrections.md
      |
      v
  4. Propose as Rule
      |
      v
  5. If Approved --> Update active-rules.md + rule-changelog.md
```

---

## Stage 1: Acknowledge

When the user corrects your behavior, explicitly acknowledge it. Examples:

- "Got it -- I should not summarize unless you ask. I will remember that."
- "You are right, I was being too verbose. I will keep responses shorter."
- "Understood. I will stop doing X and start doing Y instead."

**Do NOT** be defensive, dismissive, or overly apologetic. A brief, clear
acknowledgment is best.

---

## Stage 2: Apply Immediately

Change your behavior for the remainder of the current session. Do not wait for the
correction to be promoted to a rule -- act on it now.

If you are unsure how to apply the correction, ask for clarification:
- "Just to make sure I get this right -- do you want me to always do X, or only in
  situation Y?"

---

## Stage 3: Log to corrections.md

Write an entry to `Machine/Memory/corrections.md` using this format:

```markdown
### {Short Description}

- **Date:** YYYY-MM-DD
- **What I Did Wrong:** {description of the incorrect behavior}
- **Correct Behavior:** {what I should do instead}
- **Promoted to Rule:** pending
- **Rule Reference:** —
```

This happens immediately -- do not defer to session end.

---

## Stage 4: Propose as Rule

After logging the correction, ask the user if it should become a permanent rule:

- "Would you like me to add this as a permanent rule? It would go into my active
  rules so I remember it in every future session."
- Keep the proposal brief. Do not over-explain.

If the user says **yes**, proceed to Stage 5.
If the user says **no**, update the correction entry: `Promoted to Rule: no`.
If the user says **not now** or defers, leave it as `pending`.

---

## Stage 5: Promote to Rule

### 5a. Update active-rules.md

Add the new rule to `Machine/Rules/active-rules.md` under the appropriate section.
If no section fits, create one or add it to a "General" section.

Format the rule clearly:
```markdown
### {Rule Name}
{One or two sentences describing the rule.}
- **Added:** YYYY-MM-DD
- **Source:** User correction
```

### 5b. Update rule-changelog.md

Append an entry to `Machine/Rules/rule-changelog.md`:

```markdown
## YYYY-MM-DD: {Rule Name}
- **Action:** added
- **Description:** {what the rule says}
- **Reason:** {why it was added -- reference the correction}
```

### 5c. Update corrections.md

Update the original correction entry:
- `Promoted to Rule: yes`
- `Rule Reference: [[active-rules.md#rule-name]]`

---

## Rule Lifecycle

Rules are not permanent-forever. They can be:

### Modified
If a rule needs adjustment, the user says so. Update the rule in `active-rules.md`
and log the change in `rule-changelog.md` with `Action: modified`.

### Removed
If a rule is no longer wanted, the user says so. Remove it from `active-rules.md`
and log the removal in `rule-changelog.md` with `Action: removed`.

### Superseded
If a new rule replaces an old one, mark the old rule as superseded in the changelog
and reference the new rule.

---

## Conflict Resolution

If a new correction conflicts with an existing rule:

1. Point out the conflict to the user.
2. Ask which behavior they prefer.
3. Update or remove the conflicting rule.
4. Log both the correction and the rule change.

Example:
- "I have an existing rule that says I should always use formal language. Your
  correction suggests I should be more casual. Which would you like me to follow
  going forward?"

---

## Guardrails

- **Never self-promote a rule without user approval.** The proposal step is mandatory.
- **Never silently modify active-rules.md.** Every change must be logged.
- **Never delete correction history.** Corrections are append-only.
- **Limit rule count.** If `active-rules.md` grows beyond ~30 rules, suggest
  consolidating or archiving less-relevant rules.
- **Keep rules actionable.** Each rule should describe a specific behavior, not a
  vague principle. "Keep responses under 3 paragraphs" is good. "Be better" is not.
