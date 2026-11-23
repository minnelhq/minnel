# ADR 0004 — Ship the methodology as a plugin from this repository

**Status:** accepted   **Date:** 2026-11-23   **Amended:** 2026-11-23 (the git guard's settings; the `rm` match; this repo runs the plugin)

## Context
Adopting the methodology meant copying its drop-in artefacts (Appendices A–O) into a project.
The copies drift, and every new project repeats the copying. `docs/packaging-as-a-plugin.md`
had named a Claude Code plugin as the endpoint: one directory that bundles the agents, hooks and
skills, installed by any project.

The pieces to package already existed as Markdown in the appendices. The open questions were
where the plugin lives, which copy is the source, how the rituals ship, and how the guards behave
in a project that isn't this one. The plugin-build plan (`docs/plans/archive/plugin-build.md`)
worked through them and records each decision with its date. This ADR keeps the ones a future
change would have to reverse on purpose.

Some plugin mechanics shaped the answers. Checked against the Claude Code docs on 2026-11-22
(they cite up to v2.1.330; the installed CLI was v2.1.273):
- `rules/` is not a plugin component, and a plugin's `CLAUDE.md` is not loaded, so the Definition
  of Done can't ship as a rule.
- Plugin agents ignore `hooks` in frontmatter, so `test-writer`'s guard can't travel inside the
  agent file.
- `PreToolUse` input carries `agent_type` when a subagent makes the call, so a plugin hook can
  act on one agent's edits only.
- The docs call `commands/` the older format and prefer `skills/` for new plugins.

## Decision
Ship the plugin, **Minnel**, from this repository.

- **Location.** It lives in `plugin/`. A marketplace at the repo root,
  `.claude-plugin/marketplace.json`, lists it with `"source": "./plugin"`. The document and the
  plugin share one version and one CHANGELOG.
- **Source of truth.** The plugin files are the source. The appendices keep their embedded copies
  so each stays readable on its own. Check E in `.claude/hooks/docs-consistency.sh` compares each
  appendix artefact with the plugin file it ships as, and `templates/CLAUDE.template.md` with the
  scaffold's copy, and flags any difference outside a listed set of intended ones.
- **Rituals as skills.** `/minnel:plan`, `/minnel:accept`, `/minnel:retro`, `/minnel:release` and
  `/minnel:wrap` ship as skills with `disable-model-invocation: true`. They run only when the user
  invokes them, which is what §10 asks of a ritual command. The appendices still show them as
  `.claude/commands/` files for use without the plugin.
- **Project files by scaffold.** What a plugin can't ship (`CLAUDE.md`, the Definition of Done
  rule, the plan, backlog, ADR and changelog skeletons) is written into the project by
  `/minnel:scaffold`, which skips any file that already exists unless the user names it.
- **Guards on by default.** The bash and git guards from Appendix C, and the test-directory guard
  for `test-writer`, run in every project that installs the plugin. The git guard lets commits
  through and asks before a push; a project sets `MINNEL_GIT_GUARD_COMMITS` or
  `MINNEL_GIT_GUARD_PUSHES` to `allow`, `ask` or `block` in its `.claude/settings.json` `env` to
  change either. (Amended: the guard first blocked both, with `MINNEL_GIT_GUARD_COMMITS=0` to
  turn both off. Blocking stopped commits and pushes the user had asked for. A commit stays local,
  so it now passes; a push still waits for the user's approval.) The block on blanket staging
  (`git add -A`, `--all`, `.`, `git commit -a`) can't be turned off.
- **Version.** `plugin.json` has no `version` until the release that first ships the plugin. That
  release sets it to the CHANGELOG version, and the two stay equal after that.

## Consequences
- An adopter installs with one command (two before Claude Code 2.1.292) and runs
  `/minnel:scaffold` once, rather than copying files. The install instructions live in
  `docs/packaging-as-a-plugin.md`.
- A manifest `version` takes priority over the commit, so every install, this repo's own included,
  stays on the cached copy until a release raises the version. A plugin fix merged to `main`
  reaches installs only at the next release, so every release sets the version, and the
  Definition of Done says so. (Added 2026-11-23, when 0.4.0 first set the version.)
- The repo now ships code to adopters, not only Markdown. `plugin/scripts/tests/guards.sh` checks
  the guards against sample tool calls, and the Definition of Done adds a plugin item: that check,
  and `claude plugin validate` on `plugin` and on the root.
- Every artefact has two copies, the appendix's and the plugin's. Check E keeps them equal, but
  its pairs table and normalisers are code to maintain: a new artefact needs a row, and a new
  intended difference needs a normaliser that doesn't hide real drift. (Amended: this repo also
  kept its own copies of the rituals and reviewer in `.claude/` until PR #23. It now enables the
  plugin in `.claude/settings.json` and runs the plugin's rituals, reviewer and guards, so what it
  uses is what an adopter installs.)
- The guards act on projects this repo never sees. `bash-guard` blocks `rm` with a recursive and
  a force flag in any order or cluster (`-rf`, `-fr`, `-r -f`, `--recursive --force`) where a
  command starts. It is a tripwire for slips, not a sandbox, and it will still block some
  legitimate clean-ups; the message tells the user to run the command themselves. Revisiting the
  default is on the backlog. (Amended: the guard first matched `rm -rf` anywhere in the text, so a
  `grep` pattern or a commit message tripped it, and `rm -fr` got past.)
- `test-writer`, the bash and git guards, and the scaffold ship without the use the other pieces
  have had in this repo, so they go against the "Recommended sequencing" advice in the packaging
  doc. The doc says which pieces have had less use. (Amended: the guards have run here since this
  repo began running the plugin, but 0.4.0, the release that first ships them in the plugin,
  rewrote their matching rules, so they stay on this list.)
- (Amended: a consequence noting that §10 still recommended commands for rituals, with a note on the
  backlog, was dropped once §10 said the plugin ships them as skills.)

## Alternatives considered
- **A separate plugin repository** — rejected: the document and the plugin would version apart,
  and a change to an artefact would need two pull requests in step.
- **Appendices as the source, plugin generated from them** — rejected: it adds a build step to a
  repo whose source has none, and the extraction would be as fragile as Check E without its
  failure being visible in review.
- **Appendices that point at the plugin files instead of embedding them** — rejected: an appendix
  should read on its own, on the site and in a copy made without the plugin.
- **Rituals as `commands/`** — rejected: the plugin docs mark it the older format, and skills with
  `disable-model-invocation` give the same user control.
- **Guards off by default** — rejected: a guard an adopter must remember to enable protects only
  the adopters who need it least. The git guard's settings cover the case found for it: a project
  that lets Claude commit or push. `bash-guard` has no opt-out (see Consequences).
