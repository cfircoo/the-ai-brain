---
name: ingest
description: Import external content into the vault
---

Run the `ingest` skill to consume external content.

Accepts a file path (PDF, text), URL, or raw pasted text. Asks the user what is salient about the content before processing. Extracts key points, converts to Obsidian-compliant markdown with proper frontmatter, tags, and wikilinks to existing notes. Saves to Machine/ingested/ as a staging area for review -- never writes raw content directly to Human/. Offers integration options after processing.
