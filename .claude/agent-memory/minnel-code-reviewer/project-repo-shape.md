---
name: project-repo-shape
description: What the claude-methodology repo is, its structure, and the load-bearing invariants every review must check
metadata:
  type: project
---

This repo *is* the methodology it documents: prose, plus the Minnel plugin in `plugin/` (shell guards, JSON manifests, skills and agents; see [[project-plugin-minnel]]), versioned with the docs since 0.4.0.

Key structure (2026-06, plugin lines 2026-11-23):
- `docs/methodology.md` — main reference, narrative §1–§11 (§11 = Security). Appendices A–P (16) now live in `docs/appendices/*.md`, grouped by type (subagents, hooks, skeletons, skills-and-commands) with a `README.md` index; all present and resolving. `/plan` J, `/accept` K, `/retro` L, `/release` M, `/wrap` N, `/triage` P; security checklist O.
- `docs/packaging-as-a-plugin.md` — plugin companion. Does NOT discuss licensing.
- Gitignored local-only working notes may be present — don't treat them as a defect.
- `.claude/` — live dogfooding: `definition-of-done.md` rule, the consistency hook, the `add-section` and `close-plan` skills; settings enable the Minnel plugin, whose rituals, guards and `minnel:code-reviewer` run here (no repo copies since 2026-11-23). `test-writer` comes from the plugin; `.claude/` has no copy of its own.

**Why:** the internal-consistency invariant is load-bearing — §N cross-refs and appendix letters A–P must all resolve, and a renumber must move every reference. Appendix refs now resolve cross-file (body in methodology.md → headings in docs/appendices/*.md); the consistency hook validates appendix letters against docs/appendices/.
**How to apply:** every review, verify §refs against actual `## N.` headings and appendix refs against actual `## Appendix X` headings; verify British English and ISO `YYYY-MM-DD` dates (the product docs now use ISO throughout; a DD/MM/YYYY date in an in-scope doc is a regression); verify CHANGELOG [Unreleased] claims match what the docs actually contain. See [[feedback-recurring-defects]].
