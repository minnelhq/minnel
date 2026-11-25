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

### 0.8.0
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H — why now: the scaffold copies templates and leaves the placeholders; a bootstrap would
  ask for language and spelling, date format, commit style, changelog format, private-notes path,
  where the active-plan pointer lives and the review gate, then fill the `CLAUDE.md` Conventions
  block, the Definition of Done, `CHANGELOG.md` and `docs/backlog.md`. It answers the
  configurable-preferences stance, and the `commit-msg` hook and the guards' default build on it.
- Revisit the guards' default — feat · value M · effort L — why now: the plugin ships the guards on.
  The git guard now lets commits through and asks before a push, with a per-project setting for
  each, but `bash-guard` and the blanket-staging block have no setting. Have the bootstrap offer the
  guards and their settings. The hooks docs give no way to turn off one plugin's hooks: only
  `disableAllHooks`, or disabling the plugin (checked 2026-11-23).
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now: a
  `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates the project's stated
  commit style (which the bootstrap records; Conventional Commits by default). It catches human
  commits too and must not clash with the git-guard. Add a check that a `feat`/`fix` commit also
  touches `[Unreleased]`.
- Say whether a release cut keeps an empty Unreleased section — fix · value L · effort L — why
  now: `/release` step 5 (and Appendix M) proposes the version heading "in place of" Unreleased,
  but the 0.7.1 cut kept an empty `## [Unreleased]` above it, as Keep a Changelog and §8 do.
  Reword the step to match, in both copies (Check E).

## Later / maybe
- (none)

## Parked (with reason)
- (none)
