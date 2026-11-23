---
name: project-memory-scope-precedence
description: The §1 context table loading column and "No automatic precedence between scopes" note — what they claim, how verified, and the traps (user rules, rules without paths, "project rules" ambiguity)
metadata:
  type: project
---

`docs/methodology.md` §1 carries the context table and a bold-lead note **"No automatic
precedence between scopes."** It claims Claude Code concatenates memory files (managed → user →
project → local, broadest first) with no automatic scope precedence, resolving a conflict
arbitrarily, so the scopes must be kept consistent.

**Why:** verified against code.claude.com/docs/en/memory on 2026-11-22 (0.3.0 review) and again
on 2026-11-23 (branch fix/context-table-loading, CLI v2.1.273). Treat as version-gated —
re-verify before changing it (see the auto-memory `verify-version-gated-claude-code-claims`).

Facts the docs state (2026-11-23): nested subdirectory `CLAUDE.md` loads once Claude reads,
writes or edits a file there; parent-directory files load at launch, root down; project
`.claude/rules/` without `paths` load at launch "with the same priority as `.claude/CLAUDE.md`";
with `paths`, on Read/Write/Edit of a match; user `~/.claude/rules/` load before project rules,
neither overrides. **Not stated by the docs:** that a user rule without `paths` loads at launch.
It does in practice: the user's `~/.claude/rules/*.md` files were in this reviewer's initial
context on 2026-11-23. Any prose asserting it rests on observation, not the cited page.

**How to apply:**
- A `.claude/rules/` file without `paths` costs as much as `CLAUDE.md`. Any prose that says
  "move it to `.claude/rules/`" to save context (the "Keep `CLAUDE.md` lean" paragraph, §10's
  "`.claude/rules/` is conditional") is only true for path-scoped rules. The Appendix E DoD has
  no `paths`, so it loads every session; check it isn't described as conditional.
- "Project rules" is ambiguous in §1: the table's second row is literally "Project rules +
  invariants" (`CLAUDE.md`), but prose also uses it for `.claude/rules/`. Flag it where it matters.
- The working-agreement wording ("apply alongside these; neither scope automatically overrides
  the other, so keep them consistent") lives in `CLAUDE.md`, `templates/CLAUDE.template.md` and
  the scaffold's template copy (Check E pair). Grep `apply alongside` to catch a stranded copy.
  The template's "live in `~/.claude/CLAUDE.md`" lagged §1 once §1 named `~/.claude/rules/` too.

See [[feedback-recurring-defects]] item 10.
