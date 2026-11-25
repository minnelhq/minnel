# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. Next is grouped
under a heading for the release each item is meant for, earliest first, then Unscheduled; Later is
never grouped by release. When an item ships, move its user-facing outcome to
`CHANGELOG.md [Unreleased]` and delete the line here (§8). Now is the active-plan pointer: it names
the plan's file, with no stage count, or reads "(none — no active plan)". British English; dates
ISO YYYY-MM-DD.

## Now (this plan)
- Release 0.9.0: the --no-verify guard and a line-length check — plan: docs/plans/release-0.9.0.md

## Next

### 0.9.0
- A line-length check in the consistency hook — feat · value L · effort L — why now: in the 0.8.0
  review the reviewer caught spliced over-long lines twice (`plugin/README.md`, then
  `CHANGELOG.md`), left by swapping a sentence in a hard-wrapped file without reflowing it. The
  house-voice self-test names the defect, but nothing checks it. Flag any line over 100 columns
  in the hard-wrapped files: `CHANGELOG.md`, `plugin/README.md`, `CONTRIBUTING.md`, plans and the
  backlog. The narrative docs keep one paragraph per line, so they stay out of scope.

### Unscheduled
- (none)

## Later / maybe
- (none)

## Parked (with reason)
- (none)
