---
name: brain-setup
description: Initialize The AI Brain in the current directory. Hybrid mode — silently infers from existing context when possible, interviews the user when context is sparse. Can spawn a sub-agent to gather profile information without interrupting the main session.
---

<objective>
Initialize The AI Brain persistent memory system in the current working directory. Uses a hybrid approach: silently read existing context clues first, only ask questions when context is insufficient. Creates the vault architecture (Human/ and Machine/ hemispheres), memory files, session log templates, behavioral rules, and generates agent-specific config files (CLAUDE.md, .cursorrules, GEMINI.md, AGENTS.md).
</objective>

<protocol>

## Step 0: Dependency Check

Before anything else, silently check for required and optional tools. Use `command -v <tool>` or `which <tool>` to detect each one.

### Required (brain will not work without these)

| Tool | Check | Why needed |
|------|-------|-----------|
| `git` | `command -v git` | Vault version control |
| `jq` | `command -v jq` | JSON processing in hooks |

### Optional (brain works without these, but degrades)

| Tool | Check | Benefit if present |
|------|-------|-------------------|
| `python3` | `command -v python3` | Obsidian CLI JSON parsing in hooks |
| `yq` | `command -v yq` | Better YAML parsing in generators |
| `obsidian` | `command -v obsidian` + `obsidian version` | 70,000x faster vault search via CLI (requires Obsidian running) |

### If anything is missing:

**For REQUIRED tools** — show what's missing and ask:
```
Missing required dependencies: [list]
Install them now? [Y/n]
```

If yes, detect the package manager and install:
```bash
# macOS
brew install git jq

# Ubuntu/Debian
sudo apt-get install -y git jq

# Arch
sudo pacman -S git jq

# Windows (winget)
winget install Git.Git jqlang.jq

# Windows (choco)
choco install git jq
```

Detect package manager priority: `brew` → `apt-get` → `pacman` → `winget` → `choco` → manual instructions.

After installing, re-verify. If still missing after install attempt, stop and tell the user to install manually.

**For OPTIONAL tools** — show a summary and actively offer to install each missing one:

```
Optional tools:
  ✅ python3  — found
  ⬜ yq       — not found  → Install now for better YAML parsing? [Y/n]
  ⬜ obsidian — not found  → Install now for 70,000x faster vault search? [Y/n]
```

Ask about each missing optional tool individually. If the user says yes (or just presses Enter — default is Y), install it.

**Install yq:**
```bash
# macOS
brew install yq

# Ubuntu/Debian
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Arch
sudo pacman -S go-yq

# Windows (winget)
winget install MikeFarah.yq
```

**Install Obsidian:**

If yes, install by platform:

**macOS** — no Homebrew cask; use direct download:
```bash
echo "Download Obsidian from: https://obsidian.md/download"
echo "Or direct DMG: https://github.com/obsidianmd/obsidian-releases/releases/latest"
open "https://obsidian.md/download"
```

**Windows** — winget (recommended):
```powershell
winget install Obsidian.Obsidian --accept-package-agreements --accept-source-agreements
```

**Linux** — AppImage (official) or Flatpak:
```bash
# AppImage (recommended)
OBSIDIAN_VERSION="1.12.7"
wget "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}.AppImage" -O ~/Obsidian.AppImage
chmod +x ~/Obsidian.AppImage
~/Obsidian.AppImage &

# OR Flatpak
flatpak install flathub md.obsidian.Obsidian

# OR Snap (community-maintained)
sudo snap install obsidian --classic
```

**Linux AppImage sandbox fix** (if you get a SUID sandbox error):
```bash
sudo chown root:root /tmp/.mount_obsidi*/chrome-sandbox 2>/dev/null
sudo chmod 4755 /tmp/.mount_obsidi*/chrome-sandbox 2>/dev/null
```

After triggering the Obsidian install, **STOP and wait**. Display:

```
⏸ Obsidian needs a few manual steps before setup can continue.

  1. Finish installing Obsidian from the download above
  2. Open Obsidian and create or open a vault
  3. Go to Settings → General → Advanced → find "Command Line Interface"
  4. Toggle it ON → click "Register CLI"
  5. Open a NEW terminal session
  6. Run: obsidian version  ← confirm this works

  Note: Obsidian must stay running in the background for CLI commands to work.

Type "done" when you've completed these steps, or "skip" to continue without Obsidian CLI.
```

**Do not proceed until the user types "done" or "skip".**

- If "done": re-run `obsidian version` to verify. If it works, show ✅ and continue. If it still fails, show the error and ask them to check the steps again.
- If "skip": note that Obsidian CLI is disabled and continue with raw file reads.

---

## Step 0b: Check for Existing Brain

Check if `.brain/` already exists in the current working directory.
- **If it exists:** Ask the user if they want to re-sync/update or abort. On update, preserve all existing Human/ and Machine/ content — only regenerate agent configs and add missing files.
- **If not:** Proceed with fresh setup below.

---

## Step 1: Context Intelligence (Run silently, no output)

Before asking the user anything, scan for existing context clues. Collect everything you can infer:

**Scan these sources silently:**
- `README.md` or `README` → infer project domain, tech stack, purpose
- `CLAUDE.md` → read owner name, role, any existing rules
- `.git/config` + `git log --oneline -10` → infer domain from commit messages
- `package.json` / `pyproject.toml` / `Cargo.toml` → infer tech stack and role
- Existing folders at root → infer work type (src/, docs/, clients/, content/)
- Any `.md` files at root → scan for personal context

**Build a confidence score:**
- Found name → +20pts
- Found role/domain → +25pts
- Found tech stack or work type → +20pts
- Found existing notes or personal files → +15pts
- Directory name is descriptive (not "tmp", "test") → +10pts
- git history with 5+ commits → +10pts

**If total ≥ 60pts → go to Step 2A (auto-infer mode)**
**If total < 60pts → go to Step 2B (interview mode)**

---

## Step 2A: Auto-Infer Mode (high context)

Silently infer the full profile without asking anything. Then show the preview:

```
I found enough context to build your vault. Here's what I inferred:

👤 Owner:    [name or "you"]
💼 Role:     [inferred role]
🎯 Domain:   [inferred domain/stack]
📦 Scope:    [work only / work + personal]

Here's your vault:

📁 [current directory name]/
├── Human/
│   ├── Daily/          Daily notes and quick captures
│   ├── Projects/       [role-specific: e.g. "client work" or "features"]
│   └── Archive/        Completed items — never deleted
├── Machine/
│   ├── Memory/         AI-managed: entities, decisions, corrections
│   ├── Rules/          Self-updating behavioral rules
│   ├── Session-Logs/   Session continuity logs
│   └── Templates/      Note templates
└── .brain/             Brain engine metadata + hooks

Slash commands you'll have:
  /brain-today    — morning startup, loads all context
  /brain-new      — brain-dump anything, routes it automatically
  /brain-tldr     — summarize and save any session
  /brain-debrief  — end-of-day ritual

Type "build it" to create this, or tell me what to change.
```

Wait for confirmation before building anything.

---

## Step 2B: Interview Mode (low context)

Display this exactly, then wait:

```
Tell me about yourself in a few sentences so I can build your vault.

Answer these in whatever order feels natural:
- What do you do for work?
- What falls through the cracks most — what do you wish you tracked better?
- Work only, or personal life too?
- Do you have existing files to import? (PDFs, docs, slides)

No need to be formal. A few sentences is enough.
```

After they respond, infer silently (do NOT ask follow-up questions) and show the same vault preview as Step 2A, but personalized to what they described.

**Role → folder mapping:**
- Business owner → `Human/Projects/` + `Human/People/` + `Human/Decisions/`
- Developer → `Human/Projects/` + `Human/Research/`
- Consultant → `Human/Clients/` + `Human/Research/`
- Creator → `Human/Content/` + `Human/Research/`
- Student → `Human/Notes/` + `Human/Research/`
- If personal scope → also add `Human/Personal/`

---

## Step 2C: Sub-Agent Profile Mode (optional, advanced)

If the user says something like "figure it out yourself", "you already know me", or "check the context":

Spawn a focused sub-agent with this prompt:
```
You are a vault profiler. Your job is to infer a user profile for an AI Brain vault setup.

Read the following sources in this directory: README.md, CLAUDE.md, any .md files, package.json, git log.
Then answer these questions with your best inference:
1. Owner name (or "unknown")
2. Role (business owner / developer / consultant / creator / student / other)
3. Primary domain or stack
4. Scope: work-only or work+personal
5. Top 2 pain points (what falls through the cracks)
6. Any existing files to import? (yes/no, what types)

Return a JSON object with these fields. Confidence 0-100 for each field.
```

Use the sub-agent's JSON output to populate the vault preview. Present it to the user as: "Here's what I figured out from context..."

---

## Step 3: Build After Confirmation

Once the user says "build it", "yes", "go", "looks good", or similar — proceed.

### 3a. Create Directory Structure

Create all directories (skip any that already exist):

```
Human/Daily/
Human/Projects/     (or role-specific folders from Step 2)
Human/Archive/
Machine/Session-Logs/
Machine/Memory/
Machine/Rules/
Machine/Templates/
Machine/Canvases/
.brain/hooks/
.brain/agent-configs/
```

If personal scope: also create `Human/Personal/`

### 3b. Create Memory Files

Create in `Machine/Memory/` (skip if exists):

**entities.md** — People, Projects, Tools, Preferences sections
**decisions.md** — Decisions log with rationale
**corrections.md** — AI behavior corrections log
**context-cache.md** — Active context, current focus, quick reference

### 3c. Create Rules

**Machine/Rules/active-rules.md** with 7 default rules:
1. Startup: read this file + context-cache + latest session log before work
2. Human/ protection: read freely, write ONLY when explicitly asked
3. Machine/ access: read and write freely
4. Formatting: use [[wikilinks]] + YAML frontmatter (if Obsidian mode)
5. Memory: log entities, decisions, corrections to Machine/Memory/
6. Session end: write session log to Machine/Session-Logs/ before ending
7. Self-improve: when corrected, log it and propose a rule update

### 3d. Create Templates

Create in `Machine/Templates/`:
- `daily.md` — frontmatter + Priorities + Tasks + Notes + Carryover sections
- `project.md` — frontmatter + Overview + Goals + Tasks + Decisions + Notes
- `session-log.md` — frontmatter + Summary + Decisions + Files Modified + Next Steps + Corrections

### 3e. Write Brain State

`.brain/state.json`:
```json
{
  "brain_version": "1.0.0",
  "installed_at": "[ISO timestamp]",
  "last_session": null,
  "sessions_count": 0,
  "obsidian_cli": false
}
```

`.brain/brain.yaml` — write full config with inferred profile values.

### 3f. Detect Obsidian CLI

Run: `obsidian version 2>/dev/null`

If it returns output: set `obsidian_cli: true` in brain.yaml and state.json. Tell the user "Obsidian CLI detected — enhanced vault integration enabled."

If not found: note in summary that CLI is optional and how to enable it.

### 3g. Generate Agent Configs

Generate `CLAUDE.md` at vault root. Include:
- Owner name and role (from inferred/provided profile)
- Vault structure map with purpose of each directory
- Startup protocol (read rules → context-cache → last session log → today's note)
- Obsidian CLI command table (if CLI detected)
- Directory permissions (Human=read-only, Machine=read-write)
- Formatting conventions
- Memory, session end, and self-improvement protocols

Ask which other agents to configure (Cursor, Gemini CLI, Codex) — or skip this question if they already told you in Step 2.

### 3h. Install Hooks (Claude Code)

Create in `.brain/hooks/`:
- `session-start.sh` — reads state + session logs + context-cache + active-rules + today's note → outputs `userPromptPrefix` JSON
- `post-session.sh` — outputs `userPromptSuffix` reminder to write session log, updates state.json
- `post-edit-check.sh` — detects changes to active-rules.md, suggests /brain-vault-align

Make all scripts executable: `chmod +x .brain/hooks/*.sh`

Create/merge `.claude/settings.json` with hook configuration.

---

## Step 4: Context Injection

After building, ask:

```
One last thing — how do you want your vault context loaded into Claude Code?

1. Global (recommended) — loads your vault context automatically in every Claude Code
   session on this machine (adds one line to ~/.claude/CLAUDE.md)
2. Vault-scoped — works automatically when you run 'claude' from inside this folder
3. Manual — I'll give you the line to paste where you need it
```

If **Global** selected: append to `~/.claude/CLAUDE.md` (create if needed):
```markdown
## My Personal Brain
At the start of every session, read [absolute vault path]/CLAUDE.md for context about who I am, my work, and my conventions.
```

If **Manual**: show the line to paste.

---

## Step 5: Final Summary

```
✅ Your AI Brain is live.

📁 Vault: [path]
🧠 Memory: 4 files initialized
📋 Rules: 7 default rules active
🔗 Hooks: session continuity installed
⚡ Obsidian CLI: [detected / not detected]

Your slash commands:
  /brain-today    — run this tomorrow morning
  /brain-new      — drop any thought, it gets routed automatically
  /brain-tldr     — summarize and save this session
  /brain-debrief  — end-of-day ritual

[If files to import:]
  Drop files into Human/Projects/ then run:
  /brain-ingest [path] — extracts signal, creates clean notes

[If Obsidian not detected:]
  Optional: Install Obsidian 1.12+ → Settings → General → Enable CLI
  Re-run /brain-setup to activate enhanced vault integration.
```

</protocol>

<rules>
- NEVER overwrite existing files — skip and report what was skipped
- In Step 1, scan silently — do NOT narrate the scanning process to the user
- Do NOT ask more than one question (the free-text prompt in 2B) unless the user explicitly invites more
- Make smart inferences; present them in the preview as facts, not questions
- ALWAYS use ISO dates (YYYY-MM-DD) in all generated files
- ALWAYS make hook scripts executable with chmod +x
- The `open -a Obsidian` command is macOS only — skip it on Linux/Windows
- Never hard-code paths — always use the actual current working directory
- Create a git commit after setup if the directory is already a git repo
</rules>

<success_criteria>
- Brain detects context automatically when available (no unnecessary questions)
- User sees a personalized vault preview before anything is created
- Nothing is built until user confirms
- .brain/ exists with state.json and brain.yaml
- Human/ and Machine/ hemisphere structure exists
- All 4 memory files created in Machine/Memory/
- active-rules.md exists with 7 default rules
- CLAUDE.md generated at vault root
- Hook scripts are executable
- Context injection configured per user's choice
- User sees clear final summary with next steps
</success_criteria>
