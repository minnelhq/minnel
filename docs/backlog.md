# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. A Next item
may name its release with `target: X.Y.Z`; Later items carry none. When an item ships, move its
user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line here (§8). Now is the
active-plan pointer: it names the plan's file, with no stage count, or reads "(none — no active
plan)". British English; dates ISO YYYY-MM-DD.

## Now (this plan)
- (none — no active plan)

## Next
- Document how adopters loosen Minnel's user-only skills — feat · value M · effort L · target: 0.7.0
  — why now: all seven skills set `disable-model-invocation: true`, so Claude can't start one even
  when a message asks for it by its short name. The Claude Code skills docs give no per-skill
  override for a plugin skill (checked 2026-11-23). Naming the skill in full in the message
  (`/minnel:triage`) did start it in a desktop-app session on Claude Code 2.1.330 (observed
  2026-11-24). Test that in the CLI, then document it as the recommended route. Keep the other two
  for an adopter who wants Claude to start a skill unprompted: copy it to `.claude/skills/` without
  the key, accepting that the copy drifts from plugin updates, or fork the plugin and load the fork.
  Write the answer into "Install this plugin" in `docs/packaging-as-a-plugin.md`. Keep the key on
  all seven: an adopter can loosen a skill but can't tighten one Claude is already allowed to start.
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H · target: 0.8.0 — why now: the scaffold copies templates and leaves the placeholders; a
  bootstrap would ask for language and spelling, date format, commit style, changelog format,
  private-notes path, where the active-plan pointer lives and the review gate, then fill the
  `CLAUDE.md` Conventions block, the Definition of Done, `CHANGELOG.md` and `docs/backlog.md`. It
  answers the configurable-preferences stance, and the `commit-msg` hook and the guards' default
  build on it.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M
  · target: 0.8.0 — why now: a `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that
  validates the project's stated commit style (which the bootstrap records; Conventional Commits by
  default). It catches human commits too and must not clash with the git-guard. Add a check that a
  `feat`/`fix` commit also touches `[Unreleased]`.
- Revisit the guards' default — feat · value M · effort L · target: 0.8.0 — why now: the plugin
  ships the guards on. The git guard now lets commits through and asks before a push, with a
  per-project setting for each, but `bash-guard` and the blanket-staging block have no setting.
  Have the bootstrap offer the guards and their settings. The hooks docs give no way to turn off one
  plugin's hooks: only `disableAllHooks`, or disabling the plugin (checked 2026-11-23).

## Later / maybe
- Draw the packaging doc's appendix ↔ plugin pairs under Check E as a Mermaid diagram — feat ·
  value L · effort L — why now: left over from the 0.5.0 diagrams; it would show which appendix each
  plugin file must match.

## Parked (with reason)
- (none)
