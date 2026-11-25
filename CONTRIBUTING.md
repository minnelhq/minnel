# Contributing

Minnel is mostly Markdown: the methodology under `docs/` and the starter template under
`templates/`. The plugin under `plugin/` adds shell scripts with their own tests. None of it needs a
build.

## Conventions

[`CLAUDE.md`](CLAUDE.md) sets the project's conventions: British English, ISO dates, Conventional
Commits and a changelog entry for each user-facing change. Prose follows the
[house voice](.claude/rules/house-voice.md). The
[Definition of Done](.claude/rules/definition-of-done.md) lists what a change must clear before it
merges, and which checks apply to it. To add, remove or rename a methodology section or appendix,
use the [`add-section`](.claude/skills/add-section/SKILL.md) skill, which updates the
cross-references and counts that depend on it.

## How this repository uses Minnel

[`.claude/settings.json`](.claude/settings.json) installs the Minnel plugin from GitHub's `main`,
so its rituals, guards and `minnel:code-reviewer` run here as they would for an adopter. A merged
edit to `plugin/` reaches this repo only after a release raises the plugin's version and the
install is updated. To try an edit before then, start Claude Code with
`claude --plugin-dir ./plugin`.

The Markdown has no build or test step. The `PostToolUse`
[consistency hook](.claude/hooks/docs-consistency.sh), a script Claude Code runs after each edit,
flags US spellings, full dates not in ISO `YYYY-MM-DD`, broken intra-repo links, and dangling §
cross-references and appendix letters (A–Q). It also flags a stale "Last updated" line, an
appendix that has drifted from the plugin file it ships as, and a line over 100 columns in a
hard-wrapped file such as this one or `CHANGELOG.md`. Review covers the rest.

## Checks

Before merging a change to `plugin/` or `.claude-plugin/`, run the guard and `commit-msg` hook
tests and both plugin validations:

```sh
plugin/scripts/tests/all-awks.sh
```

```sh
claude plugin validate plugin
```

```sh
claude plugin validate .
```

Before merging a change to a published doc, `mkdocs.yml`, `requirements.txt` or
`.github/workflows/docs.yml`, build the site strictly, as CI does (see below for the setup):

```sh
.venv/bin/zensical build --strict
```

## Building the site locally

The site is built with [Zensical](https://zensical.org/), pinned in `requirements.txt`. It needs
Python 3.11 or later. Set it up once, then serve the site at <http://localhost:8000>:

```sh
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
```

```sh
.venv/bin/zensical serve
```

`zensical serve` only warns about a broken link, so run the strict build above before opening a
pull request. The decision records explain the setup:
[0002](docs/design/0002-publish-as-doc-site.md) on publishing a site at all,
[0003](docs/design/0003-build-site-with-zensical.md) on Zensical,
[0005](docs/design/0005-deploy-the-site-on-push.md) on deploying from `main` and
[0006](docs/design/0006-self-host-mermaid.md) on the pinned mermaid.js.
