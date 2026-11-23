# Packaging the Methodology as a Plugin

*Companion to "Minnel: a file-first operating model for Claude Code". Last updated 2026-11-23.*

---

## Why this is the endpoint, not an extra

Everything the methodology builds — the `code-reviewer` and `test-writer` subagents, the git and format hooks, the `.claude/rules/` Definition of Done, the ritual commands (`/plan`, `/accept`, `/retro`, `/release`, `/wrap`), the skills — currently lives scattered across a project's `.claude/` directory and `settings.json`. That works for one repo. The moment you want the same setup in a second project, you are copy-pasting, and the copies drift.

A **plugin** is the smallest unit of distribution for a Claude Code setup: one directory that bundles agents, skills, hooks, and MCP wiring, with a small manifest, installable into any project in one step. So the practical payoff is that your operating model stops being per-project scaffolding and becomes one versioned thing you drop in anywhere.

The strategic payoff matters more, and it is the reason to treat this as the natural conclusion of the whole exercise. A methodology aimed at experienced engineers travels further as an *installable, opinionated harness* ("here is my Claude Code operating model, `plugin install` it") than as a document of principles. For a methodology meant for others, the plugin is what people adopt and the document explains why.

> **Versioning note.** Plugin mechanics move quickly. What follows was checked on 2026-11-23 against the official plugin docs (which cite Claude Code up to v2.1.330) and run on v2.1.273. Confirm the manifest schema and directory conventions against the plugins reference before relying on them, and update Claude Code if `claude plugin` is not recognised.

---

## Install this plugin

This repository ships the methodology as a plugin in `plugin/`, listed by a marketplace at the repository root. From a terminal:

```bash
claude plugin marketplace add tcrossland/claude-code-methodology
claude plugin install minnel@minnel
```

Pass `--scope project` or `--scope local` to the install to limit it to one project. Inside a session, `/plugin` opens the same catalogue.

Then, in each project that adopts it:

1. Run `/minnel:scaffold`. A plugin cannot ship project files, so this writes them: `CLAUDE.md`, the Definition of Done rule, `docs/plans/`, `docs/backlog.md`, `docs/design/` and `CHANGELOG.md`. It skips any file that already exists, and the write under `.claude/` asks for your approval.
2. Fill in the placeholders it reports. The build, test and lint commands in `CLAUDE.md` and the Definition of Done come first, because `/minnel:accept` checks against them.
3. Use the rituals as §10 describes: `/minnel:plan`, `/minnel:accept`, `/minnel:retro`, `/minnel:release` and `/minnel:wrap`. They run only when you invoke them.

What else is active once installed:

- The `code-reviewer` and `test-writer` subagents, listed as `minnel:code-reviewer` and `minnel:test-writer`.
- The Appendix C guards on every `Bash` call. `bash-guard` blocks a forced recursive `rm`, a force push and `DROP TABLE`, and `git-guard` blocks blanket staging (`git add -A`, `git add .`, `git add -u`, `git commit -a`), lets other commits through and asks you to approve each `git push`. A project changes either by setting `MINNEL_GIT_GUARD_COMMITS` or `MINNEL_GIT_GUARD_PUSHES` to `"allow"`, `"ask"` or `"block"` under `env` in its `.claude/settings.json`; the block on blanket staging stays on. Where nobody can answer the prompt, as in a `-p` run, an "ask" is refused. Both guards read the command as text, so they catch slips, not a command hidden in a variable, an alias or `sh -c`.
- A test-directory guard that confines `test-writer`'s edits to `test/`, `tests/`, `__tests__/`, `spec/` or `specs/`. It catches slips rather than a determined workaround: a file written through `Bash` isn't covered.

The guards need `jq`. Without it they cannot read the tool call, and they let it through rather than block everything. The bash and git guards also need `command-segments.awk`, which ships beside them; if it goes missing, they block every `Bash` call and say why.

The reviewer, the Definition of Done and the five rituals have run on this repository across its releases. The bash and git guards have run here only since it began running the plugin, and 0.4.0 rewrote their matching rules. `test-writer` and the scaffold ship as the appendices give them and have had less use still. Treat the guards, `test-writer` and the scaffold as starting points.

---

## The shape of a plugin

Claude Code prefers **convention over configuration**: get the directory shape right and components are discovered automatically. This repository's plugin:

```
plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest: name, description, author, licence
├── agents/                  # Subagents, one .md file each
│   ├── code-reviewer.md
│   └── test-writer.md
├── skills/                  # One subdirectory per skill
│   ├── plan/SKILL.md        # the five rituals
│   ├── accept/SKILL.md
│   ├── retro/SKILL.md
│   ├── release/SKILL.md
│   ├── wrap/SKILL.md
│   └── scaffold/            # writes the project files
│       ├── SKILL.md
│       └── templates/
├── hooks/
│   └── hooks.json           # Same format as settings.json hooks
└── scripts/                 # Hook scripts
    ├── bash-guard.sh
    ├── git-guard.sh
    ├── command-segments.awk # splits a command line for the two guards
    ├── tests-dir-guard.sh
    └── tests/guards.sh      # sample tool calls for each guard
```

A plugin can also bundle `commands/`, `.mcp.json` (MCP servers), `.lsp.json`, `monitors/`, `output-styles/` and `bin/` (executables added to `PATH`); consult the plugin component reference for the full auto-discovered set.

The manifest needs only a `name`; `claude plugin validate` warns when `version`, `description` or `author` is missing. A minimal one:

```json
{
  "name": "my-methodology",
  "description": "An opinionated, file-first Claude Code operating model for solo developers.",
  "version": "0.1.0"
}
```

Four rules that prevent the usual silent failures:

- **Component folders live at the plugin root, never inside `.claude-plugin/`.** Nesting them there makes the plugin load while its components silently vanish — the single most common structural mistake.
- **Use `${CLAUDE_PLUGIN_ROOT}` for every intra-plugin path.** A hook that references `./scripts/git-guard.sh` by an absolute or home-relative path works on your machine and breaks on anyone else's. `${CLAUDE_PLUGIN_ROOT}/scripts/git-guard.sh` is portable. Quote it in a hook command, as in `"${CLAUDE_PLUGIN_ROOT}"/scripts/git-guard.sh`, so an install path with a space still runs.
- **`.claude/rules/` is not a plugin component directory.** Rules load from the *project*, not from a plugin. Verified on Claude Code v2.1.181 (2026-06-19): with a test plugin enabled, its bundled `rules/` (and `.claude/rules/`) never fired while its commands did, and the plugin component reference omits `rules/` from the auto-discovered set. The 2026-11-23 docs check agrees, and adds that a plugin's own `CLAUDE.md` is not loaded either. So ship project conventions — the Definition of Done especially — as a skill that writes them into the project, as this plugin's scaffold does, or as instructions in the agents that need them.
- **Prefer `skills/` to `commands/`.** The plugin docs call `commands/` the older format; it still loads. A skill with `disable-model-invocation: true` runs only when you invoke it by name, which is the property §10 wants from a ritual command.

After install, a plugin's skills are **namespaced** under the plugin name, e.g. `/my-methodology:retro`, and its agents become `my-methodology:<agent>`. That avoids collisions with a project's own.

---

## What to package — and what to leave out

How this plugin maps the methodology's appendices:

| Methodology piece | Plugin component | Notes |
|---|---|---|
| `code-reviewer`, `test-writer` (Appendix A, B) | `agents/*.md` | See the agent caveat below |
| Project hooks + git guard (Appendix C) | `hooks/hooks.json` + `scripts/` | Hook format is identical to `settings.json` |
| `/plan`, `/accept`, `/retro`, `/release`, `/wrap` (Appendices J–N) | `skills/<name>/SKILL.md` | `disable-model-invocation: true`, so only you start them |
| Plan, Definition of Done, backlog, ADR and changelog skeletons (Appendices D–H) | `skills/scaffold/` | Writes them into the project; a plugin cannot bundle `.claude/rules/` |
| `add-importer` and similar (Appendix I) | not shipped | An illustration; project-specific procedures stay in the project's `.claude/skills/` |
| Security checklist (Appendix O) | not shipped | A judgement list to run, not an action to automate |

Each shipped artefact also appears in its appendix, so the document stays readable without the plugin. This repository's consistency hook compares every pair and flags drift.

**One important agent caveat.** Plugin-shipped subagents support `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation` (only `worktree`) and a few others. For security reasons they do **not** support `hooks`, `mcpServers`, `permissionMode` or `initialPrompt` in frontmatter; those are silently ignored when an agent loads from a plugin. So the `test-writer` agent's frontmatter `PreToolUse` guard (Appendix B) will not travel inside the plugin. This plugin moves that guard to `hooks/hooks.json`. A `PreToolUse` hook receives `agent_type` (here `minnel:test-writer`) when a subagent makes the call, so `tests-dir-guard.sh` acts on that agent's edits and lets every other edit through.

**Curate, do not dump.** The fastest way to build a bad plugin is to copy your whole `.claude/` directory into it. That carries your machine-specific paths, personal endpoints, and experiment-grade half-skills into something other people install. A plugin is a product, not a backup of your setup. Decide deliberately what is general (ships) versus what is project-specific or personal (stays local). This repository's own `.claude/`, tuned for a documentation project, stays out of the plugin for that reason.

---

## Migration path (you already have most of it)

If the methodology is already running in a project, conversion is mechanical:

1. `mkdir -p my-methodology/.claude-plugin` and write `plugin.json`.
2. `cp -r .claude/agents my-methodology/`, same for `skills/`. Turn each `.claude/commands/<name>.md` into `skills/<name>/SKILL.md` with a `name` and `disable-model-invocation: true` in its frontmatter. Positional arguments count from zero (`$0` is the first, `$1` the second), so prefer `$ARGUMENTS` where one argument is expected.
3. Move your `settings.json` hooks into `hooks/hooks.json` (the format is the same, under a top-level `"hooks"` key) and rewrite script paths to `${CLAUDE_PLUGIN_ROOT}/...`. Move any agent frontmatter hooks there too.
4. Check it: `claude plugin validate ./my-methodology`, then `claude --plugin-dir ./my-methodology plugin details my-methodology` to list what loaded. Run each component once in a scratch project before you trust it.
5. When you want others to install it, publish through a **marketplace**: a `.claude-plugin/marketplace.json` that lists the plugin and points at its source (a GitHub repo is the common host; a subdirectory such as `./plugin` works). Installers then run `claude plugin install my-methodology@your-marketplace`.

---

## Recommended sequencing

Don't build the whole plugin up front. Run the methodology unpackaged in one real project until the agents, hooks, and a handful of skills have earned their place through actual use — the retro habit (§8) is what tells you which pieces are worth keeping. *Then* package the proven set. A plugin assembled from battle-tested components is a product; one assembled from speculation is a liability you have to maintain.

When you package it for others, the plugin and the document are a pair: ship the plugin as the adoptable artefact, keep the document as the rationale that explains *why* each component is shaped the way it is. The document earns trust; the plugin earns adoption.
