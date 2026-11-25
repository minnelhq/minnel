# Minnel

Minnel is a file-first operating model for Claude Code. Plans, decisions, the backlog and the
changelog live in files, so work survives compaction and a restart. This plugin packages the
methodology's artefacts so a project can adopt them without copying files by hand.

## What it ships

- Two subagents: `minnel:code-reviewer`, which reviews a branch's final diff before merge and
  reports findings without fixing them, and `minnel:test-writer`, which writes behaviour-driven
  tests.
- Three guard hooks: `bash-guard` (forced recursive `rm`, force push, `DROP TABLE`), `git-guard`
  (blanket staging, `git commit -a` included; by default it also asks before each push) and a
  test-directory guard for `test-writer`. They catch slips, not a determined command. A project
  can set what the bash and git guards do to allow, ask or block.
- Seven skills: the rituals `/minnel:plan`, `/minnel:accept`, `/minnel:retro`, `/minnel:release`,
  `/minnel:wrap` and `/minnel:triage`, and `/minnel:scaffold`, which asks for the project's
  conventions and writes the project files a plugin cannot ship, filled in with them.
  `/minnel:retro` proposes additions to the project's configuration and prunings of it, starting
  from `config-audit.sh`, a read-only script that lists each rule and memory file's length and
  the paths they name that no longer exist.

## Install

On Claude Code 2.1.292 or later:

```bash
claude plugin install minnel --marketplace minnelhq/minnel
```

Inside a session, `/plugin install minnel --marketplace minnelhq/minnel` works
from 2.1.275. From the shell before 2.1.292, add the marketplace first:

```bash
claude plugin marketplace add minnelhq/minnel
claude plugin install minnel@minnel
```

Then run `/minnel:scaffold` in each project that adopts it. The guards need `jq`.

To move to a later release, update the plugin and start a new session. The update refreshes the
marketplace first.

```bash
claude plugin update minnel@minnel
```

## More

- [The methodology](https://minnelhq.github.io/minnel/methodology/) explains
  what each piece is for.
- [Install this plugin](https://minnelhq.github.io/minnel/plugin/#install-this-plugin)
  covers install scopes, updates, the scaffold's steps, the guards' settings and which pieces have
  had less use.
