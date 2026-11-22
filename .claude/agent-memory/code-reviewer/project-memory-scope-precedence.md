---
name: project-memory-scope-precedence
description: The §1 "No automatic precedence between scopes" note — what it claims, how it was verified, and the within-scope vs cross-scope line to keep clean
metadata:
  type: project
---

`docs/methodology.md` §1 carries a bold-lead note **"No automatic precedence between scopes."**
It claims Claude Code concatenates memory files (managed → user → project → local) with no
automatic scope precedence, resolving a user/project conflict arbitrarily, so the two must be
kept consistent.

**Why:** verified against code.claude.com/docs/en/memory.md (docs citing up to v2.1.283) on
2026-11-22, during the 0.3.0 release review. Treat as a version-gated claim — re-verify before
changing it (see the auto-memory `verify-version-gated-claude-code-claims`).

**How to apply:**
- Keep the note's cross-scope claim distinct from the §1 table's within-project-nesting line
  "Nested files append; closest-to-cwd wins". They are different axes (scope vs directory
  depth). Any edit that lets the note's "later in context does not make it win" reach into the
  nested-project case contradicts the table. Flagged this tension at the 0.3.0 review as a
  readability risk, not a hard contradiction.
- The matching working-agreement wording ("apply alongside these; neither scope automatically
  overrides the other, so keep them consistent") lives in both `CLAUDE.md` and
  `templates/CLAUDE.template.md` — they must stay identical. Grep `apply alongside` / `apply on
  top` to catch a stranded copy.
