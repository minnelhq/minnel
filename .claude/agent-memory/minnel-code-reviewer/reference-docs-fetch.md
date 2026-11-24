---
name: reference-docs-fetch
description: Where to fetch Claude Code and Claude model docs as Markdown with curl to verify version-gated or model-ID claims
metadata:
  type: reference
---

Both doc sites return Markdown when the page path ends in `.md` (worked with plain `curl -sSL`, 2026-11-24):

- Claude Code commands reference: `https://code.claude.com/docs/en/commands.md`. Built-in commands appear in its table without a "**[Skill]**" tag; bundled skills carry one. `/security-review` was untagged (built-in) on 2026-11-24.
- Models overview: `https://platform.claude.com/docs/en/about-claude/models/overview.md`. Its "Claude API ID" row holds the current IDs (2026-11-24: `claude-fable-5-2`, `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5`).
- Claude Code's own CHANGELOG for version gates: see [[feedback-plugin-review]].

Save fetched pages in the scratchpad and grep them there. Re-fetch rather than trusting the IDs above: §5's example IDs go stale with each model release.
