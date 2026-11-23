# Plan: Commit style and changelog format as adopter choices   (approved 2026-11-23)

**Status:** in progress — Stage 3 of 3
<!-- Active-plan pointer: docs/backlog.md "Now (this plan)". Branch: feat/conventions-as-choices. -->

## Goal
Present the commit style and the changelog format as choices the adopter names in their
`CLAUDE.md` Conventions, with Conventional Commits and Keep a Changelog as stated defaults, and
have `/release` and `/wrap` read them. Fold in two `/release` fixes on the same files: an ISO date
for the version heading, and Keep a Changelog's hyphen as its separator.

Why: §8 says "Adopt Keep a Changelog" and assumes Conventional Commits, while the template offers
a commit style only as an example and has no changelog line, and `/release` (Appendix M)
hard-codes the Keep a Changelog categories. The methodology already treats language and tone as
the adopter's choice; this does the same for these two.

Keep a Changelog 1.1.0 (read from keepachangelog.com on 2026-11-23) writes version headings as
`## [1.1.1] - 2023-03-05`, recommends ISO dates for release dates, and says improving an existing
changelog is fine. So the ISO date belongs to the default format, not to the author's own
preference.

Each edited artefact has a copy that Check E pairs with it: Appendix M with
`plugin/skills/release/SKILL.md`, Appendix N with `plugin/skills/wrap/SKILL.md`, and
`templates/CLAUDE.template.md` with `plugin/skills/scaffold/templates/CLAUDE.md`. Change both
sides together.

## Out of scope
- This repo's own `CLAUDE.md`: its Conventions already name its commit style, and its `/release`
  copy hard-codes its own format.
- Enforcing a convention (a `commit-msg` hook); that is a separate backlog item.
- Mapping other commit styles to changelog categories beyond a sentence; the default mapping stays
  implicit, as today.
- Renumbering anything: no § or appendix letter moves.
- Cutting a release or setting the plugin version.

---

## Stage 1 — Template and §8   [done]
- [x] `Commit style:` in the template's Conventions reads as a default to keep or replace; a new
      `Changelog:` line beside it names Keep a Changelog with SemVer as the default. Same two
      edits in the scaffold's copy — files: `templates/CLAUDE.template.md`,
      `plugin/skills/scaffold/templates/CLAUDE.md`
- [x] §8's changelog paragraph presents Keep a Changelog as the recommended default the project
      names in its Conventions, keeping the reasons; "its Conventional Commits" becomes the
      commits in the project's stated style (Conventional Commits by default). The backlog-tag
      sentence stays — files: `docs/methodology.md`
- [x] Check §1's context table and "No automatic precedence" paragraph against the new wording;
      change them only if they contradict it.
- Acceptance: Check E passes for the CLAUDE template pair; the consistency hook passes on
  `methodology.md`; §8 no longer reads as a mandate, and the template names both choices.

## Stage 2 — The rituals read the conventions; release heading fixes   [done]
- [x] Appendix M `/release`: step 1 also reads the `Commit style:` and `Changelog:` lines, with
      the defaults when absent; step 3 sorts into that format's categories (for the default,
      Added, Changed, Deprecated, Removed, Fixed, Security); step 5 writes the format's heading
      (for the default, `## [$ARGUMENTS] - YYYY-MM-DD`, today's date in ISO) — files:
      `docs/appendices/skills-and-commands.md`, `plugin/skills/release/SKILL.md`
- [x] Appendix N `/wrap` step 1 drafts changelog entries in the format the project's Conventions
      name — files: `docs/appendices/skills-and-commands.md`, `plugin/skills/wrap/SKILL.md`
- [x] Appendix H's example version headings use `-`, not `—`; its `[Unreleased]` head is
      unchanged, so the scaffold's `CHANGELOG.md` pair is unaffected — files:
      `docs/appendices/skeletons.md`
- [x] This repo's copies: `.claude/commands/release.md` writes `## [$ARGUMENTS] - <today's date>`
      and stays an adapted copy that hard-codes this repo's format; `CHANGELOG.md`'s four release
      headings (0.1.0–0.3.1) use the hyphen.
- Acceptance: Check E passes for Appendices H, M and N, and catches a deliberate one-word drift in
  Appendix N, which is then reverted; `git grep -n '\] — '` finds no version heading in
  `CHANGELOG.md`, Appendix H, Appendix M, the plugin release skill or the repo's `release.md`;
  `zensical build --strict` builds cleanly.

## Stage 3 — Records and review   [current]
- [x] `CHANGELOG.md` `[Unreleased]` lines go in with the commits they describe: Changed (§8 and
      the template present both as defaults the project names; `/release` and `/wrap` read
      them), Fixed (`/release` writes the version heading with an ISO date and a hyphen; this
      changelog's headings now use the hyphen too).
- [x] `docs/backlog.md`: the three items this plan ships are out of Next, and `## Now` points at
      this plan.
- [ ] Run the `code-reviewer` on the branch diff, then `/accept` against the Definition of Done.
- Acceptance: no Critical findings; every DoD item has evidence.

---

## Deviations
- 2026-11-23, Stage 1 — also corrected `methodology.md`'s stale "Last updated" line (it read
  2026-06-20 after §9 changed on 2026-11-22). §1 needed no change: its table and the "No automatic
  precedence" paragraph already treat commit style as a convention a project can override.

## Decisions
- 2026-11-23 — The choice lives in the project's `CLAUDE.md` Conventions (`Commit style:`,
  `Changelog:`), and the rituals fall back to the defaults when a line is absent — because the
  template already carries the commit-style line, and one place to look keeps the rituals simple.
- 2026-11-23 — `/release` keeps the Keep a Changelog categories and heading spelled out as the
  default, rather than only "use the project's format" — because a ritual that names nothing
  concrete gets vague.
- 2026-11-23 — Rewrite this repo's released changelog headings to the hyphen — because Keep a
  Changelog endorses improving an existing changelog, and nothing links to those headings.
