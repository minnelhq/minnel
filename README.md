# Minnel: a file-first operating model for Claude Code

Written for experienced solo developers and small teams, it treats the harness,
[Claude Code](https://code.claude.com/docs/en/overview)'s settings, subagents, hooks and commands,
as an engineered environment: the discipline lives in
what you persist to files and what you enforce deterministically, not in clever prompting.

Adopted, it keeps a plan alive through session restarts and through compaction, when Claude Code
summarises a long conversation to free context. It also makes the rules that matter hold without
the model having to remember them. Each piece comes with the reasoning behind it, and the drop-in
artefacts can be adopted one at a time.

## What's here

- `docs/methodology.md` — the full reference: context architecture, the work loop,
  plan/status persistence, subagents, the model/mode matrix, hooks, sessions/concurrency
  and git hygiene, skills and commands, solo product discipline (backlog, changelog,
  Definition of Done, retro), and a security stance (least privilege, prompt-injection and
  plugin/MCP trust).
- `docs/appendices/` — the fifteen drop-in artefacts (subagents, hooks, document skeletons, the
  example skill and the ritual commands; Appendices A–O), grouped by type. See its `README.md` index.
- `docs/packaging-as-a-plugin.md` — how to install the plugin, how to package your own, and
  why a plugin is the natural endpoint.
- `docs/worked-example.md` — one real task (adding a link-resolution check) traced through the
  loop, end to end.
- `templates/CLAUDE.template.md` — a lean starter `CLAUDE.md`, with default conventions to keep or
  replace.
- `plugin/` — the methodology as an installable Claude Code plugin: the two subagents, the
  guards, the five rituals as skills, and a `/minnel:scaffold` skill that writes the project files.
  `.claude-plugin/marketplace.json` at the root lists it.
- `.claude/` — the methodology running live, tuned for this docs project (see *Dogfooding*):
  - settings that enable the plugin, so its five rituals (`/minnel:plan`, `/minnel:accept`,
    `/minnel:retro`, `/minnel:release`, `/minnel:wrap`), its guards and the
    `minnel:code-reviewer` subagent (a task-scoped helper with its own context) run here as they
    would for an adopter;
  - the Definition of Done rule, the bar a change must clear;
  - a `PostToolUse` consistency hook, a script Claude Code runs after each edit. It flags dangling
    §/appendix references, broken intra-repo links, US spellings, `DD/MM/YYYY` dates, and drift
    between an appendix and the plugin file it ships as;
  - two skills: `add-section` (the section/appendix cross-reference ripple) and `close-plan` (the
    plan-close sequence).

## Using it

1. Read `docs/methodology.md`.
2. Drop `templates/CLAUDE.template.md` into a project as `CLAUDE.md` and fill it in.
3. Adopt the loop, the file layout (`docs/plans/`, `docs/design/`, `CHANGELOG.md`) and the
   appendix artefacts (subagents, hooks, skills, commands) as they earn their place, not
   all at once.

To skip the copying, install the plugin instead (see "Install this plugin" in
`docs/packaging-as-a-plugin.md`). Its `/minnel:scaffold` writes the `CLAUDE.md` template and
the file layout into a project for you.

## Reading it as a site

The docs are published as a site at <https://tcrossland.github.io/claude-code-methodology/>,
built with [Zensical](https://zensical.org/): the same Markdown, with search and navigation. To
build it locally:

```sh
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/zensical serve   # http://localhost:8000
```

The site build is optional, never a prerequisite for reading or editing the Markdown (see
`docs/design/0002-publish-as-doc-site.md` and `docs/design/0003-build-site-with-zensical.md`).
CI builds and checks the site on every pull request and every push to `main`; publishing it to
GitHub Pages is a manual run of the `docs` workflow.

## Dogfooding

This repository is built using the methodology it documents. The work here gets done through
the lean root `CLAUDE.md`, the docs under `docs/`, the curated root `CHANGELOG.md`, the plugin's
rituals, guards and reviewer, and the contents of `.claude/`.

They are tuned to a documentation project. The Markdown source has no build or test step, and the
doc site is an optional publish build. Verification of the Markdown rests on British English and
the internal-consistency invariant (§ cross-references and appendix letters A–O), enforced by the
`PostToolUse` consistency hook and review rather than a test suite. The plugin adds
`plugin/scripts/tests/guards.sh` and `claude plugin validate`. That tuning doubles as a
worked example: it adapts the appendix drop-ins to a real repo rather than pasting them verbatim.
The plugin's rituals, guards and reviewer are the exception. This repo runs them unchanged, and
the project detail they need comes from `CLAUDE.md` and the Definition of Done, as it would for an
adopter. The settings install the plugin from GitHub's `main`, but a merged edit to `plugin/`
reaches that install only once a release raises the plugin's version. Even then, the install
moves only after `claude plugin marketplace update minnel` and then
`claude plugin update minnel@minnel`. The new version loads in the next session. To try an edit
before then, start Claude Code with `claude --plugin-dir ./plugin`.

## Status

I started Minnel in June 2026 and run it on my own projects. I'm its only adopter so far, so it
has had no outside feedback yet, and it may be too rigid to suit everyone. Minnel comes two ways:
the documents give the practices and the reasoning behind them, and the plugin (`plugin/`)
installs the artefacts they describe.

## Licence

[Apache-2.0](LICENSE). Permissive: use, modify, and redistribute freely, including
commercially; the methodology spreads by adoption. The licence grants no rights to the
project's name or marks (`LICENSE` §6) and carries an explicit patent grant (§3).
