# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. A Next item
may name its release with `target X.Y.Z`; Later items carry none. When an item ships, move its
user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line here (§8). British
English; dates ISO YYYY-MM-DD.

## Now (this plan)
- (none — no active plan)

## Next
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now: a
  `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates the project's stated
  commit style (Conventional Commits by default). It catches human commits too and must not clash
  with the git-guard. Add a check that a `feat`/`fix` commit also touches `[Unreleased]`.

## Later / maybe
- Draw the packaging doc's appendix ↔ plugin pairs under Check E as a Mermaid diagram — feat ·
  value L · effort L — why now: left over from the 0.5.0 diagrams; it would show which appendix each
  plugin file must match.
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
