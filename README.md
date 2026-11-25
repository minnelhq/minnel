# Minnel

A file-first way of working with [Claude Code](https://code.claude.com/docs/en/overview), for
experienced solo developers and small teams.

Long Claude Code sessions lose things. Compaction, which summarises a long conversation to free
context, can drop the plan. A restart forgets what was decided, and a rule in `CLAUDE.md` holds
only while the model remembers it. Minnel answers with two habits. What must survive goes in
files: the plan, the decisions, the backlog and the changelog. What must hold is checked by hooks
and, before merge, by a review subagent. Hooks are scripts Claude Code runs at set points in a
session, such as before or after a tool call, so they don't depend on the model remembering. The
subagent is a separate AI assistant with its own context and instructions.

## Quick start

The guards need `jq`. On Claude Code 2.1.292 or later, install the plugin:

```bash
claude plugin install minnel --marketplace minnelhq/minnel
```

Then, in a project, run `/minnel:scaffold`. It asks for the project's conventions, fills in the
project files with them, and reports what's left to fill, starting with the invariants.
[Install this plugin](docs/plugin.md#install-this-plugin) covers
older versions, install scopes and updates.

## What you get

- **Project files**, written by the scaffold: a lean `CLAUDE.md`, a Definition of Done,
  `docs/plans/`, `docs/backlog.md`, `docs/design/` and `CHANGELOG.md`, filled in with the
  conventions it asks you for. It skips any that exist, and can install a `commit-msg` hook that
  checks the commit style.
- **Six rituals**, which only you start:
  - `/minnel:plan` explores read-only and proposes a plan;
  - `/minnel:accept` checks the diff against the Definition of Done;
  - `/minnel:wrap` closes a session with the records current;
  - `/minnel:retro` proposes configuration changes and prunings;
  - `/minnel:triage` reorders the backlog and shows the roadmap;
  - `/minnel:release` drafts changelog entries, then tags and publishes a merged release.
- **Three guards** that catch slips such as a forced recursive `rm`, a force push or blanket
  staging. By default the git guard also asks before each `git push`. A project can set what
  the bash and git guards do to allow, ask or block.
- **Two subagents**: `minnel:code-reviewer`, which reviews a branch before merge, and
  `minnel:test-writer`, which writes behaviour-driven tests.

## Without the plugin

Every piece is also a drop-in file. Copy the [starter template](templates/CLAUDE.template.md)
into a project as `CLAUDE.md`, then adopt the [appendix artefacts](docs/appendices/README.md) one
at a time as they earn their place.

## Read more

- [The methodology](docs/methodology.md): what each piece is for, and why.
- [Worked example](docs/worked-example.md): one real task traced end to end.
- [Minnel as a plugin](docs/plugin.md): installing, updating and packaging your own.

The same docs are on [the site](https://minnelhq.github.io/minnel/), with search. It follows
`main`, so it can show changes no release includes yet.

## Status

Minnel is maintained. It is pre-1.0 (see the [changelog](CHANGELOG.md)), so a minor release can
change how things work. I started it in June 2026 and run it on my own projects. It has had no
outside adopters or feedback yet, and it may be too rigid to suit everyone.
[Issues](https://github.com/minnelhq/minnel/issues) and feedback are welcome.

## This repository

Minnel is developed with Minnel. The repo runs the plugin unchanged, with its own
[Definition of Done](.claude/rules/definition-of-done.md) and a
[consistency hook](.claude/hooks/docs-consistency.sh) tuned to a documentation project: a working
example of adapting the artefacts. [`CONTRIBUTING.md`](CONTRIBUTING.md) has the checks and the
site build.

## Licence

[Apache-2.0](LICENSE): use, modify and redistribute freely, including commercially. The licence
grants no rights to the project's name or marks (`LICENSE` §6) and carries an explicit patent
grant (§3).
