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

### Unscheduled
- Block `git commit --no-verify` in the bash guard — feat · value M · effort L — why now: the
  Appendix Q `commit-msg` hook is a tripwire Claude can step over with `--no-verify`. A
  `bash-guard` rule for it, under `MINNEL_BASH_GUARD` like the others, would close that gap for
  Claude's commits while people keep the escape hatch.

## Later / maybe
- (none)

## Parked (with reason)
- (none)
