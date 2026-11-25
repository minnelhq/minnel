---
name: project-house-voice
description: .claude/rules/house-voice.md (formerly docs/style.md) is the house-voice authoring guide; what it governs, how voice passes go wrong, and the heading-anchor trap
metadata:
  type: project
---

`.claude/rules/house-voice.md` ("House voice"; `docs/style.md` until 2026-11-23) is an
authoring convention for prose. It is a path-scoped rule (`*.md`, `docs/**/*.md`,
`plugin/README.md`), so it loads when a Markdown file is read or edited. Its scope line names the
narrative docs in full: `README.md`, `CONTRIBUTING.md` (added 2026-11-25), `plugin/README.md`
(added 2026-11-23), `index.md`, `methodology.md`, `worked-example.md`, `plugin.md`; it
also covers changelog entries and plan and backlog notes. Reference artefacts under
`docs/appendices/` are exempt where structure/punctuation is deliberate. `CLAUDE.md` Conventions
points at it in one line.

The rules themselves are in the file, which loads with any Markdown file; read them there
rather than from this note.

**Why:** the public docs read as AI-generated, which undercut the "human judgement, not vibes"
positioning. The guide gives future prose edits an acceptance criterion. It is explicitly *not*
about hiding that the repo is built with Claude.

**How to apply:**
- When reviewing prose edits to the narrative docs, check them against these rules, not just
  British-English/§N consistency.
- A voice pass (first one: 2026-11-23) mostly preserves meaning; the
  slips are small words and implied contrasts. Diff with `--word-diff` and check: a dropped
  restrictor ("pin ... only when" lost its "only" in §4); a new framing that implies a contrast
  the doc elsewhere denies ("Without a plugin, everything ... lives scattered" in the plugin
  doc, though its own list includes the `.claude/rules/` DoD that a plugin cannot ship, see
  [[project-plugin-minnel]]); an in-scope doc the pass skipped (`index.md` kept its bold
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
- **Path matching (observed 2026-11-23).** The rule was injected into this reviewer's context
  right after it read a file under `.claude/agent-memory/`, which only `*.md` could match. So a
  bare `*.md` matches at any depth, `docs/**/*.md` beside it is redundant (as is the DoD's
  `**/*.md`), and the rule loads for every Markdown file, appendices and plugin skills included.
  Rests on observation, not the docs; re-check before asserting it in published prose.
- Moving it out of `docs/` took it out of the consistency hook's scope (`.claude/**` is out), so
  its own spelling and links are no longer checked at edit time; check them by hand.
- It is internal authoring convention under `.claude/`, not published, so a change to it alone does not
  need a CHANGELOG line; a pass that applies it to published docs does. See
  [[feedback-recurring-defects]] and [[project-doc-site]].
