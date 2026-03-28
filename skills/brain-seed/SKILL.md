---
name: brain-seed
model: claude-opus-4-6
context: forked
description: Enrich the Obsidian knowledge graph with MOC hubs, entity notes, and cross-links. Use when the user says "seed the graph", "enrich graph", "graph seeding", "add nodes", "make graph richer", or wants to grow their knowledge graph from project context.
---

<objective>
Scan all registered projects and the hub vault, discover entities (tools, platforms, concepts, data sources, people), create MOC hub notes and entity notes with dense cross-links, fill empty wikilink stubs, and report before/after graph density stats. Idempotent — safe to run repeatedly.
</objective>

<protocol>

## Step 1: Locate the Hub Vault

1. Read `brain.yaml` in the current directory's `.brain/` to find the architecture mode
2. If Hub+Spokes: find the hub path (default `~/Brain`)
3. If no hub: operate on the current vault's root instead
4. Confirm the hub vault exists and is readable

## Step 2: Take a "Before" Snapshot

Count and record:
- Total `.md` files in the hub vault (top-level only, not Machine/ subdirs)
- Total `[[wikilinks]]` across all hub vault `.md` files
- List of all existing note filenames (to avoid overwriting)
- Orphan count: notes with 0 incoming links from other notes

## Step 3: Discover Entities from All Registered Projects

Read `{hub}/Machine/Memory/projects.md` to get all registered projects.

For **each registered project**, scan these sources silently:
- `README.md` → project purpose, tech stack
- `CLAUDE.md` → tools, conventions, domain
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` → dependencies and language
- `.brain/brain.yaml` → module type, framework
- `Machine/Memory/context-cache.md` → existing context
- `Machine/Memory/entities.md` → already-known entities
- Key source directories (scan filenames, not content — for speed)

Build a master list of:
- **Domains** → will become MOC notes (e.g., Trading, AI Tooling, Web Development, DevOps)
- **Tools** → will become entity notes (e.g., Supabase, Playwright, Vite, Docker)
- **Platforms** → entity notes (e.g., TradingView, Vercel, GitHub Actions)
- **Languages/Frameworks** → entity notes (e.g., Pine Script, React, FastAPI)
- **Data sources** → entity notes (e.g., COT, market sentiment data)
- **Concepts** → entity notes (e.g., Gann Analysis, WebSocket, MCP)
- **People** → entity notes (if referenced in project context)

**Deduplication:** Normalize names (lowercase comparison). If a note already exists in the hub vault, skip it. Only create new notes.

## Step 4: Create MOC Hub Notes

For each discovered domain, create a `MOC — {Domain}.md` note if it doesn't exist:

```markdown
---
tags: [type/MOC, domain/{domain-slug}]
created: {today}
---
# MOC — {Domain Name}

{One-line description connecting to [[{owner-name}]]'s work.}

## Projects
- [[{project}]] — {brief description}

## Tools & Platforms
- [[{tool}]] — {role in this domain}

## Concepts
- [[{concept}]] — {brief description}
```

**Rules:**
- Every MOC must link to the owner note and at least 3 other notes
- Always create `MOC — Projects` if it doesn't exist (indexes all projects)
- MOCs should cross-link to each other where domains overlap

## Step 5: Create Entity Notes

For each discovered entity (tool, platform, language, data source, concept), create `{Entity Name}.md` if it doesn't exist:

```markdown
---
tags: [type/{tool|language|data-source|concept|platform|person}, domain/{domain-slug}]
created: {today}
---
# {Entity Name}

{One-line description.}

## How [[{owner}]] Uses It
- {Usage in project 1 — with [[project-link]]}
- {Usage in project 2 — with [[project-link]]}

## Related
- [[{parent MOC}]]
- [[{related-entity-1}]]
- [[{related-entity-2}]]
```

**Rules:**
- Every entity must link to at least 1 MOC and 1 project
- Target 4-8 outgoing `[[wikilinks]]` per note
- Use bidirectional linking: if A links to B, ensure B links back to A (update B if it already exists)

## Step 6: Fill Empty Stubs

Scan all `[[wikilink]]` targets across the hub vault. For each target that:
- Has no corresponding `.md` file, OR
- Has a `.md` file that is empty (0 bytes or only whitespace)

Create or fill the note with:
- Frontmatter (tags, created date)
- Brief description inferred from the linking context
- Links back to the notes that reference it
- At least 1 MOC link

**Exceptions — do NOT create notes for:**
- Machine/ subdirectory references (like `[[active-rules]]`, `[[decisions]]`)
- Inline text fragments that aren't real entities (like `[[double-bracket]]`)
- Generic words that aren't meaningful entities

## Step 7: Enrich Sparse Notes

Scan all existing notes in the hub vault. For any note with fewer than 3 outgoing `[[wikilinks]]`:
- Add relevant cross-links to MOCs, related entities, or projects
- Ensure the owner note links to all MOCs and all projects
- Ensure all project notes link to their relevant MOCs, tools, and data sources

**Do NOT change the meaning or content** of existing notes — only add `## Related` links or append links to existing sections.

## Step 8: Report Results

Take an "After" snapshot and report:

```
🌐 Knowledge Graph Seeded

Before → After:
  Notes:      {before} → {after} (+{diff})
  Wikilinks:  {before} → {after} (+{diff})
  Orphans:    {before} → {after}

Created:
  {N} MOC hub notes: {list names}
  {M} entity notes: {list names}
  {K} stubs filled: {list names}
  {J} sparse notes enriched

Avg links per note: {total_links / total_notes}

Open Obsidian graph view to see the changes.
Next run of /brain-seed will discover any new entities from project changes.
```

</protocol>

<rules>
- NEVER overwrite existing notes — only create new ones or append links to existing ones
- NEVER fabricate entities — only create notes for things actually discovered in project context
- ALWAYS use `[[wikilinks]]` for internal references
- ALWAYS include YAML frontmatter with tags, created date
- ALWAYS use ISO dates (YYYY-MM-DD)
- Target 4-8 outgoing wikilinks per note — this is the density threshold for a useful graph
- Bidirectional linking: if you create A→B, ensure B→A exists too
- Skip Machine/ subdirectory files when scanning for stubs (they're not graph nodes)
- Run silently — don't narrate each file creation, just show the final report
- This skill is idempotent — running it twice produces the same result (no duplicates)
</rules>

<success_criteria>
- Zero orphan notes after seeding (every note has at least 1 incoming link)
- Every new note has 4+ outgoing wikilinks
- Every MOC links to the owner note and at least 3 entities
- Every entity links to at least 1 MOC and 1 project
- No existing notes were overwritten or had content removed
- Before/after stats reported clearly
- Graph view in Obsidian shows visible clusters around MOC hubs
</success_criteria>
