# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. When an
item ships, move its user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line
here (§8). British English; dates ISO YYYY-MM-DD.

## Now (this plan)
- (none — no active plan)

## Next
- Present commit style and changelog format as adopter choices with defaults — feat · value H ·
  effort M — why now: §8 prescribes Keep a Changelog and assumes Conventional Commits while the
  template offers them only as examples; state both as recommended defaults, add a `Changelog:` line
  beside `Commit style:` in the template's Conventions, and have `/release` (Appendix M) and `/wrap`
  (Appendix N) read the project's Conventions instead of hard-coding the categories.
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
  or say plainly they catch slips, not a determined command.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now:
  a `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates Conventional
  Commits (catching human commits too, without clashing with the git-guard) and a check that a
  `feat`/`fix` commit also touches `[Unreleased]`.
- Dogfood Appendix C here and check the appendices for drift — debt · value M · effort M — why now:
  this repo runs adapted copies of the J–N commands but not the git-guard, which is how its inverted
  regex went unnoticed; add a consistency-hook Check E comparing `.claude/commands/*.md` with their
  appendix versions, allowing only marked project-specific deviations.
- Appendix M `/release`: carry over the ISO date instruction — fix · value L · effort L — why now:
  this repo's own `.claude/commands/release.md` tells Claude to use ISO `YYYY-MM-DD` for any date;
  the appendix version still says `<today's date>` with no format.
- Version heading separator in `/release` and `CHANGELOG.md` — fix · value L · effort L — why now:
  Appendix M writes `## [$1] — <date>` and the changelog follows it, but Keep a Changelog's own
  examples use a hyphen (`- 2026-11-22`) and changelog parsers may expect it; change both together.

## Later / maybe
- Christen the methodology — choose the name and command/plugin namespace — chore · value M · effort L
  — why now: the working name is settled; lock the public name (`plugin.json` `name` plus the
  `/<name>:command` namespace) when the plugin ships, since renaming after publish is costly.
- Build the methodology as a plugin (the stated endpoint — `docs/packaging-as-a-plugin.md`) — feat ·
  value H · effort H — why now: deferred until the unpackaged setup has earned its pieces through
  real use ("Recommended sequencing"); note the Definition of Done must ship as a skill or a
  `CLAUDE.md` block, since a plugin cannot bundle `.claude/rules/` (verified 2026-06-19).
- Plugin bootstrap command (`/adopt` or `/init`) that asks for the adopter's conventions and writes
  them into the project — feat · value H · effort H — why now: it answers both the rules-can't-ship
  limit and the configurable-preferences stance; it would ask for language and spelling, date
  format, commit style, changelog format, private-notes path and the review gate, then write the
  `CLAUDE.md` Conventions block, `.claude/rules/definition-of-done.md`, `CHANGELOG.md` and
  `docs/backlog.md`. A larger version of the `/scaffold-docs` row in the packaging doc; lands with
  the plugin.
- Make the guards opt-in when packaged — feat · value M · effort L — why now: blocking every commit
  is a personal stance, and plugin `hooks.json` would impose it on every project that enables the
  plugin; have the bootstrap command offer to write the guards into project settings instead.
  Check whether plugin hooks can be disabled per project before the packaging doc says so.

## Parked (with reason)
- (none)
