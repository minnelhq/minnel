# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. When an
item ships, move its user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line
here (§8). British English; dates ISO YYYY-MM-DD.

## Now (this plan)
- Build the methodology as a plugin — `docs/plans/plugin-build.md`, Stage 3 of 6 — feat · value H ·
  effort H — why now: the reviewer, Definition of Done, git guard and rituals have proved
  themselves across three releases here, so the packaged set is ready to ship.

## Next
- (none)

## Later / maybe
- Christen the methodology — choose the name and command/plugin namespace — chore · value M · effort L
  — why now: the working name is settled; lock the public name (`plugin.json` `name` plus the
  `/<name>:command` namespace) when the plugin ships, since renaming after publish is costly.
  Folded into Stage 6 of the plugin plan.

## Parked (with reason)
- (none)
