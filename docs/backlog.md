# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. Next is grouped
under a heading for the release each item is meant for, earliest first, then Unscheduled; Later is
never grouped by release. When an item ships, move its user-facing outcome to
`CHANGELOG.md [Unreleased]` and delete the line here (§8). Now is the active-plan pointer: it names
the plan's file, with no stage count, or reads "(none — no active plan)". British English; dates
ISO YYYY-MM-DD.

## Now (this plan)
- Release 0.8.0: the bootstrap with its guard and hook settings — plan: docs/plans/release-0.8.0.md

## Next

### 0.8.0
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H — why now: the scaffold copies templates and leaves the placeholders; a bootstrap would
  ask for language and spelling, date format, commit style, changelog format, private-notes path,
  where the active-plan pointer lives and the review gate, then fill the `CLAUDE.md` Conventions
  block, the Definition of Done, `CHANGELOG.md` and `docs/backlog.md`. It answers the
  configurable-preferences stance, and the `commit-msg` hook and the guards' default build on it.
- Have the bootstrap offer the guards' settings — feat · value M · effort L — why now: every bash
  and git guard now takes allow, ask or block per project, but an adopter has to find the four
  `env` names. The bootstrap should ask for each and write the non-default ones.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now: a
  `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates the project's stated
  commit style (which the bootstrap records; Conventional Commits by default). It catches human
  commits too and must not clash with the git-guard. Add a check that a `feat`/`fix` commit also
  touches `[Unreleased]`.

## Later / maybe
- (none)

## Parked (with reason)
- (none)
