---
name: brain-vault-align
description: Re-sync rules and agent configs from brain.yaml
---

Run the `vault-align` skill to synchronize the vault.

Read brain.yaml and Machine/Rules/active-rules.md, compare active rules against actual vault conventions to detect drift, propose updates to active-rules.md (with user approval before changes), and regenerate all enabled agent configuration files (CLAUDE.md, .cursorrules, GEMINI.md, AGENTS.md) from current rules and templates.
