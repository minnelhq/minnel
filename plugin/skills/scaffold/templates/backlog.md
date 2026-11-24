# Backlog

Ordered top to bottom. The top item is what gets picked up next.
Tag each item — type: feat/fix/debt/chore, value: H/M/L, effort: H/M/L — and a
one-line "why now". Optional ID (BL-NN) only if you want plans or commits to
reference items. Next may group its items under a heading for the release they are
meant for ("### <version>"), earliest first, with the rest under "### Unscheduled";
the release ritual lists any item still under a version's heading when that version
is cut. Later is never grouped by release. When an item ships, move its user-facing
outcome to CHANGELOG.md (Unreleased), then delete the line here. Now names the
active plan's file, and reads "(none — no active plan)" when no plan is live.

## Now (this plan)
- [ ] <item> — plan: docs/plans/<task-name>.md — feat — value: H, effort: M — why now: <reason>

## Next

### <version>
- [ ] <item> — fix — value: M, effort: L — why now: <reason>

### Unscheduled
- [ ] <item> — feat — value: M, effort: M — why now: <reason>

## Later / maybe
- <item> — debt — <one line; deliberately not committing yet>

## Parked (with reason)
- <item> — parked YYYY-MM-DD because <reason>
