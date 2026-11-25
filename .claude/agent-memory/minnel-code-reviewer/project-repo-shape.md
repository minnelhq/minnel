---
name: project-repo-shape
description: What the claude-methodology repo is, its structure, and the load-bearing invariants every review must check
metadata:
  type: project
---

This repo *is* the methodology it documents: prose, plus the Minnel plugin in `plugin/` (shell guards, JSON manifests, skills and agents; see [[project-plugin-minnel]]), versioned with the docs since 0.4.0.

The layout is in `CLAUDE.md`'s Layout section; read it there. Three things it doesn't say:
gitignored local-only working notes may be present (not a defect), and `.claude/` holds no copies
of the plugin's rituals, guards or agents (removed 2026-11-23). The plugin doc (`docs/plugin.md`, named `packaging-as-a-plugin.md` until 2026-11-25) does not
discuss licensing.

**Why:** the internal-consistency invariant is load-bearing — §N cross-refs and appendix letters A–Q must all resolve, and a renumber must move every reference. Appendix refs now resolve cross-file (body in methodology.md → headings in docs/appendices/*.md); the consistency hook validates appendix letters against docs/appendices/.
**How to apply:** every review, verify §refs against actual `## N.` headings and appendix refs against actual `## Appendix X` headings, then work through the DoD and [[feedback-recurring-defects]].
