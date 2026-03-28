---
name: brain-ingest
model: claude-opus-4-6
context: forked
description: Consume external content into the vault with proper formatting. Use when the user says "ingest", "import", "add this article", "save this URL", "process this PDF", "read this and save it", or provides external content (file, URL, raw text) to be incorporated into the vault.
---

<objective>
Accept external content (PDF, URL, or raw text), extract salient information with user guidance, convert to Obsidian-compliant markdown with proper frontmatter and wikilinks, and save to the Machine/ staging area for review before integration into Human/.
</objective>

<protocol>

## Step 1: Identify Input Type

Determine what the user provided:

| Input | Detection | Handling |
|-------|-----------|----------|
| **File path** | Ends in `.pdf`, `.txt`, `.md`, `.html`, or is a valid file path | Read the file |
| **URL** | Starts with `http://` or `https://` | Fetch and extract content |
| **Raw text** | Everything else | Use directly |

If no input was provided, prompt: "What would you like to ingest? Provide a file path, URL, or paste the text."

## Step 2: Extract Raw Content

### For PDF files
- Read the PDF content
- Extract text, preserving structure (headings, lists, paragraphs)
- Note any images or diagrams that cannot be extracted (mention them in the output)

### For URLs
- Fetch the page content
- Extract the main article/content body (strip navigation, ads, footers)
- Capture the title, author, publication date if available
- Save the source URL for attribution

### For raw text
- Use the text as-is
- Attempt to identify structure (headings, lists, paragraphs)

## Step 3: Understand Salience

Ask the user what matters about this content before processing:

```
I have the content loaded. Before I extract key points, help me understand what is salient for you:

1. What is your goal with this content? (learning, reference, decision-making, project context)
2. Any specific sections or topics you care about most?
3. How detailed should the extraction be? (high-level summary / key points / detailed notes)
4. Any existing vault notes this relates to?

Or just say "general" and I will extract the most important points.
```

Use the user's guidance to focus the extraction. If the user says "general," extract broadly.

## Step 4: Process Content

Based on the salience guidance, extract and structure the content:

### Key Points Extraction
- Identify the main thesis or purpose
- Extract key arguments, findings, or concepts
- Note important data points, quotes, or examples
- Identify action items or implications for the user

### Structure the Output

```markdown
---
date: YYYY-MM-DD
tags: [{topic-tags}]
type: reference
source: "{URL or filename or 'raw input'}"
author: "{if known}"
ingested: YYYY-MM-DD
status: staging
---

# {Title}

> **Source:** {URL/file/raw}
> **Ingested:** {date} via ingest skill

## Summary
{2-5 sentence summary of the content}

## Key Points
- {main takeaway 1}
- {main takeaway 2}
- {main takeaway 3}

## Detailed Notes
{structured notes based on salience guidance}

## Relevance
{how this connects to existing vault content}
- Related: [[existing note 1]]
- Related: [[existing note 2]]

## Questions / Follow-ups
- {anything raised by the content worth exploring}

## Raw Quotes
> "{important quote 1}" -- {attribution}
> "{important quote 2}" -- {attribution}
```

## Step 5: Add Wikilinks

Cross-reference the ingested content with the existing vault:

1. Read `Machine/Memory/entities.md` for known entities.
2. Scan `Human/Projects/` for active projects.
3. Add `[[wikilinks]]` wherever the content references known entities, projects, or concepts that have existing notes.
4. Suggest new wikilinks for concepts that do not yet have notes but probably should.

## Step 6: Save to Staging

Save the processed note to `Machine/` (the AI zone), NOT directly to `Human/`:

**Path:** `Machine/ingested/{YYYY-MM-DD}-{slug}.md`

Where `{slug}` is a kebab-case version of the title (e.g., `2025-01-15-api-design-patterns.md`).

Create the `Machine/ingested/` directory if it does not exist.

## Step 7: Present and Offer Integration

Show the user what was created:

```
Ingested and processed. Here is what I saved:

File: Machine/ingested/{filename}.md
Source: {source}
Key points: {count}
Wikilinks: {count} connections to existing notes

Preview:
{show the Summary and Key Points sections}

Actions:
1. Move to Human/ (integrate into your notes)
2. Edit first (open for review)
3. Leave in Machine/ingested/ for now
4. Discard

What would you like to do?
```

If the user chooses to integrate:
- Move the file to the appropriate `Human/` subdirectory
- Update the `status` frontmatter field from `staging` to `integrated`
- Update today's daily note with a log entry

## Advanced: PDF and Document Pipeline

For importing large or messy documents (PDFs, DOCX, Excel, annual reports), use this pipeline to extract signal from noise:

### Sub-step A: Organize by File Type

If given a folder of mixed files:
1. Scan the directory for file types
2. Create subfolders: `PDFs/`, `DOCX/`, `Spreadsheets/`, `Other/`
3. Move files to appropriate subfolders
4. Report the organization to the user before proceeding

### Sub-step B: Extract and Synthesize

For each document:

1. **Extract raw text** using available tools (Read for text files, Bash for `pdftotext` if available)

2. **Synthesize with a focused prompt:**
   ```
   You are distilling [document type] into a knowledge artifact.
   Extract ONLY:
   - Core concepts and definitions
   - Key decisions or findings
   - Actionable insights
   - Important data points or metrics
   - Named entities (people, companies, products)

   Ignore: formatting noise, headers/footers, boilerplate, redundant text.
   Format as clean markdown with clear sections.
   ```

3. **Create a cheat-sheet note** — not a full copy, just the signal:
   ```markdown
   ---
   date: YYYY-MM-DD
   tags: [ingested, {document-type}]
   type: reference
   source: {original filename}
   ---

   # {Document Title} — Key Points

   {synthesized content}
   ```

### Sub-step C: Import to Vault

Save synthesized notes to `Human/Projects/{topic}/` or ask user for preferred location.

**With Obsidian CLI:**
```bash
obsidian open "{note-path}"  # open the new note to verify
```

### Sub-step D: Link to Related Notes

After importing, suggest connections:
- Search for existing notes on the same topic
- Offer to add `[[wikilinks]]` to related content
- Offer to update `Machine/Memory/entities.md` with new entities discovered

</protocol>

<rules>
- NEVER save raw, unprocessed content directly into the vault. Always extract and structure first.
- ALWAYS ask the user about salience before processing (unless they explicitly say "just save it").
- Save to `Machine/ingested/` first -- never directly to `Human/` without user approval.
- Preserve source attribution (URL, author, date) in frontmatter.
- Use `status: staging` frontmatter field for ingested content pending review.
- Add `[[wikilinks]]` only to genuinely relevant existing notes -- do not force connections.
- If content is very long (10+ pages), offer to split into multiple notes by topic.
- For PDFs with images/diagrams, note their existence even though they cannot be extracted as text.
- Respect copyright -- the processed note should be a summary and key points, not a verbatim copy of long-form content.
</rules>

<success_criteria>
- External content is extracted and structured as Obsidian-compliant markdown
- User's salience guidance shapes the extraction focus
- Proper frontmatter with source attribution is applied
- Wikilinks connect to relevant existing vault notes
- Content is saved to Machine/ingested/ (staging area), not directly to Human/
- User is presented with the result and given integration options
- No raw, unprocessed content is dumped into the vault
</success_criteria>
