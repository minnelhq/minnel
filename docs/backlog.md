# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. When an
item ships, move its user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line
here (§8). British English; dates ISO YYYY-MM-DD.

## Now (this plan)
- Build the methodology as a plugin — `docs/plans/plugin-build.md`, Stage 6 of 6 — feat · value H ·
  effort H — why now: the reviewer, Definition of Done, git guard and rituals have proved
  themselves across three releases here, so the packaged set is ready to ship.

## Next
- Present commit style and changelog format as adopter choices with defaults — feat · value H ·
  effort M — why now: §8 prescribes Keep a Changelog and assumes Conventional Commits while the
  template offers them only as examples; state both as recommended defaults, add a `Changelog:` line
  beside `Commit style:` in the template's Conventions, and have `/release` (Appendix M) and `/wrap`
  (Appendix N) read the project's Conventions instead of hard-coding the categories. Both also ship
  as plugin skills (`plugin/skills/`), and Check E keeps each pair matched, so edit both.
- Name user-level `~/.claude/rules/*.md` in the §1 context table — feat · value M · effort L — why
  now: the table lists only `~/.claude/CLAUDE.md` for personal conventions, yet one file per
  convention (commit style, dates, private notes) under `~/.claude/rules/` is easier to share and
  replace, and loads as user memory (seen in a live session, 2026-11-22; confirm against the memory
  docs before writing it up).
- Check how nested `./module/CLAUDE.md` files load in the §1 table — fix · value M · effort L — why
  now: the table lists them under "Always", but subdirectory `CLAUDE.md` files may load on demand
  when Claude reads files there; unverified, so check the current memory docs first.
- Appendix C guards: close the remaining bypasses or call them tripwires — fix · value M · effort L
  — why now: the bash-guard catches `rm -rf` but not `rm -fr` or `rm -r -f`, and the git-guard still
  passes `git add -Av`, `git add .;`, `:/`, `..`, `-u` and quoted dots; either broaden the patterns
  or say plainly they catch slips, not a determined command. The plugin ships the same scripts in
  `plugin/scripts/`; change both, and add the cases to `plugin/scripts/tests/guards.sh`.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now:
  a `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates Conventional
  Commits (catching human commits too, without clashing with the git-guard) and a check that a
  `feat`/`fix` commit also touches `[Unreleased]`.
- Dogfood Appendix C here, and extend Check E to this repo's commands — debt · value M · effort M
  — why now: this repo runs adapted copies of the J–N commands but not the git-guard, which is how
  its inverted regex went unnoticed. Check E now pins the plugin's copies to the appendices; extend
  it to compare `.claude/commands/*.md` too, allowing only marked project-specific deviations.
- Appendix M `/release`: carry over the ISO date instruction — fix · value L · effort L — why now:
  this repo's own `.claude/commands/release.md` tells Claude to use ISO `YYYY-MM-DD` for any date;
  the appendix version still says `<today's date>` with no format. Change
  `plugin/skills/release/SKILL.md` with it, since Check E pairs them.
- Version heading separator in `/release` and `CHANGELOG.md` — fix · value L · effort L — why now:
  Appendix M writes `## [$ARGUMENTS] — <date>` and the changelog follows it, but Keep a Changelog's
  own examples use a hyphen (`- 2026-11-22`) and changelog parsers may expect it; change the
  appendix, the plugin's release skill and the changelog together.

## Later / maybe
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H — why now: the scaffold copies templates and leaves the placeholders; a bootstrap would
  ask for language and spelling, date format, commit style, changelog format, private-notes path
  and the review gate, then fill the `CLAUDE.md` Conventions block, the Definition of Done,
  `CHANGELOG.md` and `docs/backlog.md`. It answers the configurable-preferences stance.
- Revisit the guards' default — feat · value M · effort L — why now: the plugin ships the guards on,
  and `MINNEL_GIT_GUARD_COMMITS=0` turns off the commit and push block per project (verified live
  2026-11-23). Blocking every commit is a personal stance; consider having the bootstrap offer the
  guards instead. Whether a project can disable a plugin's hooks wholesale is still unverified.
- §10: say a ritual can ship as a skill — feat · value L · effort L — why now: §10 says to use
  commands for rituals, while the plugin ships them as skills with `disable-model-invocation:
  true`, which behave like commands; say so, so §10 and the packaging doc read as one.

- Decide whether the methodology's title takes the Minnel name — chore · value L · effort L — why
  now: the plugin is named Minnel, but the docs still title the methodology "A File-First Operating
  Model for Claude Code"; choose one before the first release that ships the plugin.
- Quote `$CLAUDE_PROJECT_DIR` in hook commands — fix · value L · effort L — why now: the packaging
  doc now says to quote `${CLAUDE_PLUGIN_ROOT}` so a path with a space still runs, but Appendices B
  and C and this repo's `.claude/settings.json` leave `$CLAUDE_PROJECT_DIR` unquoted, and project
  paths with spaces are common. Check E doesn't compare B's hooks block, so it can change alone.

## Parked (with reason)
- (none)
