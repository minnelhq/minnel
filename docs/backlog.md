# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. Next is grouped
under a heading for the release each item is meant for, earliest first, then Unscheduled; Later is
never grouped by release. When an item ships, move its user-facing outcome to
`CHANGELOG.md [Unreleased]` and delete the line here (§8). Now is the active-plan pointer: it names
the plan's file, with no stage count, or reads "(none — no active plan)". British English; dates
ISO YYYY-MM-DD.

## Now (this plan)
- (none — no active plan)

## Next

### 0.7.0
- Retitle `docs/plugin.md` to match its scope — debt · value L · effort L — why now: the rename
  left the H1 ("Packaging the methodology as a plugin") and the site nav label ("Packaging as a
  plugin"), and site readers see the label, not the file name. The title covers only packaging,
  though the doc also says how to install and use Minnel. Update every place that quotes or
  paraphrases it: the H1, the nav in `mkdocs.yml`, `docs/index.md` (twice),
  `docs/appendices/README.md` and `docs/methodology.md` §10. ADR 0002's "packaging companion" is a
  record of the time, so it stays.

### 0.8.0
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H — why now: the scaffold copies templates and leaves the placeholders; a bootstrap would
  ask for language and spelling, date format, commit style, changelog format, private-notes path,
  where the active-plan pointer lives and the review gate, then fill the `CLAUDE.md` Conventions
  block, the Definition of Done, `CHANGELOG.md` and `docs/backlog.md`. It answers the
  configurable-preferences stance, and the `commit-msg` hook and the guards' default build on it.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now: a
  `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates the project's stated
  commit style (which the bootstrap records; Conventional Commits by default). It catches human
  commits too and must not clash with the git-guard. Add a check that a `feat`/`fix` commit also
  touches `[Unreleased]`.
- Revisit the guards' default — feat · value M · effort L — why now: the plugin ships the guards on.
  The git guard now lets commits through and asks before a push, with a per-project setting for
  each, but `bash-guard` and the blanket-staging block have no setting. Have the bootstrap offer the
  guards and their settings. The hooks docs give no way to turn off one plugin's hooks: only
  `disableAllHooks`, or disabling the plugin (checked 2026-11-23).

## Later / maybe
- Draw `docs/plugin.md`'s appendix ↔ plugin pairs under Check E as a Mermaid diagram — feat ·
  value L · effort L — why now: left over from the 0.5.0 diagrams; it would show which appendix each
  plugin file must match.

## Parked (with reason)
- (none)
