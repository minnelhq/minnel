# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. When an
item ships, move its user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line
here (§8). British English; dates ISO YYYY-MM-DD.

## Now (this plan)
- `docs/plans/release-0.5.0.md` — prepare release 0.5.0, Stage 1 of 4

## Next
- Add release targets to the backlog format — feat · value M · effort M · target 0.5.0 — why now:
  nothing says which release a Next item is meant for, so `/minnel:release` cannot warn that an item
  meant for the version is still open. The type tags suggest each item's SemVer bump (`feat` a
  minor, `fix` a patch; `debt` and `chore` none unless an adopter would notice). No widely adopted
  backlog standard plays Keep a Changelog's role; keep the Now–Next–Later shape Appendix F already
  has (credit Janna Bastow at ProdPad if §8 explains it), and add an optional `target X.Y.Z` per
  Next item or `### X.Y.Z` subsections under Next. Leave Later ungrouped, since the shape exists to
  avoid promises the far end can't keep. A shipped item's line is deleted (§8), so `/minnel:release`
  checks the other way: it lists any Next item still targeting the version. Change Appendix F with
  the scaffold's backlog copy, and Appendix M with the plugin's `release` skill (Check E pairs the
  appendix and plugin copies), and say so in §8.
- Add a backlog-triage ritual — feat · value M · effort M · target 0.5.0 — why now: triage has been
  done by hand three times (PRs #16 and #19, and the change that put the guards first), past §10's
  twice-by-hand test. A skill would check that each item still applies (shipped, out of date or
  duplicated), re-tag and reorder Next, and propose release groups, as a draft for approval. When a
  project keeps a backlog in its gitignored notes (confirmed with `git check-ignore`), it reads that
  too, but shows the combined grouping only in the chat or writes it to those notes; the tracked
  backlog groups tracked items only and names a private blocker in general terms. Ship it as an
  appendix after O with its plugin skill, since the packaging doc gives every shipped artefact an
  appendix; that widens the A–O range, so use `add-section` and plan mode. Update §10's ritual table
  and every "five rituals" count (§10 twice, README, the packaging doc, the appendix intro). Do it
  after the release-targets item.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now: a
  `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates the project's stated
  commit style (Conventional Commits by default). It catches human commits too and must not clash
  with the git-guard. Add a check that a `feat`/`fix` commit also touches `[Unreleased]`.
- Add Mermaid diagrams where the prose describes a flow — feat · value M · effort M · target 0.5.0 —
  why now: the docs have none, and the §2 loop is one arrow line that hides its back-edges.
  Candidates: the §2 loop, the §8 backlog → plan → changelog lifecycle, the §6/§11 hook path
  (`PreToolUse` guards, then the `PostToolUse` check) and, lower value, the packaging doc's appendix
  ↔ plugin pairs under Check E. Enable Zensical's `mermaid` custom fence in `mkdocs.yml`, set
  `layout: dagre` in each chart's frontmatter, draw left to right with short labels, and keep the
  prose beside each diagram so the Markdown stays readable on its own. Before shipping, check where
  Zensical loads Mermaid from (a CDN is a third-party script on the site) and view each chart on
  GitHub at desktop width and 375 px.

## Later / maybe
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H — why now: the scaffold copies templates and leaves the placeholders; a bootstrap would
  ask for language and spelling, date format, commit style, changelog format, private-notes path
  and the review gate, then fill the `CLAUDE.md` Conventions block, the Definition of Done,
  `CHANGELOG.md` and `docs/backlog.md`. It answers the configurable-preferences stance.
- Revisit the guards' default — feat · value M · effort L — why now: the plugin ships the guards on.
  The git guard now lets commits through and asks before a push, with a per-project setting for
  each, but `bash-guard` and the blanket-staging block have no setting. Consider having the
  bootstrap offer the guards and their settings. The hooks docs give no way to turn off one
  plugin's hooks: only `disableAllHooks`, or disabling the plugin (checked 2026-11-23).

## Parked (with reason)
- (none)
