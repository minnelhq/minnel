# Backlog

Ordered top to bottom. The top item is what gets picked up next.
Tag each item — type: feat/fix/debt/chore, value: H/M/L, effort: H/M/L — and a
one-line "why now". Optional ID (BL-NN) only if you want plans or commits to
reference items. A Next item may name the release it is meant for with
"target: <version>"; /release lists any still open when that version is cut.
Later items carry no target. When an item ships, move its user-facing outcome to
CHANGELOG.md (Unreleased), then delete the line here.

## Now (this plan)
- [ ] <item> — feat — value: H, effort: M — why now: <reason>

## Next
- [ ] <item> — fix — value: M, effort: L — target: <version> — why now: <reason>

## Later / maybe
- <item> — debt — <one line; deliberately not committing yet>

## Parked (with reason)
- <item> — parked YYYY-MM-DD because <reason>
