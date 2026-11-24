---
name: retro
description: Run a methodology retro — surface recurring friction, propose config changes and prunings.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/config-audit.sh)
disable-model-invocation: true
---

Review what we had to correct repeatedly during this plan. For each recurring issue,
propose the single most durable fix and say where it belongs:

- a CLAUDE.md invariant or convention,
- a `.claude/rules/` entry,
- a PreToolUse/PostToolUse hook,
- a new or amended subagent or skill.

Then prune. Run `${CLAUDE_PLUGIN_ROOT}/scripts/config-audit.sh` and start from its
output: each file's line count and the paths they name that no longer exist. Read the
files it lists (`CLAUDE.md`, `.claude/rules/`, `.claude/agent-memory/` and my
`~/.claude/` rules, among others) and list each entry that:

- the finished plan made obsolete;
- repeats another entry or a Definition of Done item;
- names a file, flag or version that no longer holds;
- contradicts an entry in another scope (no scope takes precedence, so one must go).

Propose a delete, a merge or a rewrite for each.

Output a short list of concrete changes only — no narrative. Do not apply them; I will
review first.
