---
name: project-house-voice
description: docs/style.md is the house-voice authoring guide; what it governs, how voice passes go wrong, and the heading-anchor trap
metadata:
  type: project
---

`docs/style.md` ("House voice") is an authoring convention for prose in the narrative public
docs. As of 2026-11-23 its scope line names five: `methodology.md`, `README.md`, `index.md`,
`worked-example.md`, `packaging-as-a-plugin.md` (the packaging doc was added that day). Reference
artefacts under `docs/appendices/` are exempt where structure/punctuation is deliberate. It is
`exclude_docs` in `mkdocs.yml` (not published) and pointed at from `CLAUDE.md` Conventions by one
line.

Its rules: lead with the point (no throat-clearing openers), prefer short sentences, vary
rhythm, em-dashes sparingly (one per paragraph max), drop formulaic constructions ("not just X
but Y", "it's not X it's Y", default rule-of-three triads, "Note that"/"It's important to"/
"Simply"), cut hedging ("quite"/"fairly"/"arguably"/"in many cases"), no emoji/decorative bold.

**Why:** the public docs read as AI-generated, which undercut the "human judgement, not vibes"
positioning. The guide gives future prose edits an acceptance criterion. It is explicitly *not*
about hiding that the repo is built with Claude.

**How to apply:**
- When reviewing prose edits to the narrative docs, check them against these rules, not just
  British-English/§N consistency.
- A voice pass (first one: 2026-11-23, Stage 4 of the 0.4.0 plan) mostly preserves meaning; the
  slips are small words and implied contrasts. Diff with `--word-diff` and check: a dropped
  restrictor ("pin ... only when" lost its "only" in §4); a new framing that implies a contrast
  the doc elsewhere denies ("Without a plugin, everything ... lives scattered" in the packaging
  doc, though its own list includes the `.claude/rules/` DoD that a plugin cannot ship, see
  [[project-plugin-rules-claim]]); an in-scope doc the pass skipped (`index.md` kept its bold
  emphasis while README dropped it).
- **Heading anchors.** Removing an em-dash from a heading does not change the site's anchor
  (Zensical's slug strips punctuation and collapses runs: `11-security-the-trust-boundary`
  either way; verified by building both revisions), but GitHub's slug turns each space into a
  hyphen, so `11-security--the-trust-boundary` becomes `11-security-the-trust-boundary`. A
  changelog or plan line about "new anchors" must say which renderer, and must name every
  heading that changed. Check with `git grep -nE "\.md#|\]\(#"` for in-repo links.
- The guide must obey its own rules (it currently does: zero em-dashes in its prose as of the
  2026-06-20 review; em-dashes appear only inside its "Before:" anti-examples). If you edit it,
  re-run the self-test it documents.
- It deliberately *cross-references* the British-English and §N/appendix rules rather than
  restating them; keep it that way to avoid the duplication defect.
- It is internal authoring convention, excluded from the site, so a change to it alone does not
  need a CHANGELOG line; a pass that applies it to published docs does. See
  [[feedback-recurring-defects]] and [[project-doc-site]].
