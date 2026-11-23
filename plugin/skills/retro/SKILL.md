---
name: retro
description: Run a methodology retro — surface recurring friction and propose config changes.
disable-model-invocation: true
---

Review what we had to correct repeatedly during this plan. For each recurring issue,
propose the single most durable fix and say where it belongs:

- a CLAUDE.md invariant or convention,
- a `.claude/rules/` entry,
- a PreToolUse/PostToolUse hook,
- a new or amended subagent or skill.

Output a short list of concrete changes only — no narrative. Do not apply them; I will
review first.
