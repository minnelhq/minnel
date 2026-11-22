---
name: scaffold
description: Set up the project files the methodology relies on, which a plugin cannot ship itself — CLAUDE.md, the Definition of Done rule, docs/plans/, docs/backlog.md, docs/design/ and CHANGELOG.md.
argument-hint: "[files to overwrite]"
disable-model-invocation: true
---

Set up this project for the methodology. The templates are in `${CLAUDE_SKILL_DIR}/templates/`.

| Template | Project path |
|---|---|
| `CLAUDE.md` | `CLAUDE.md` |
| `definition-of-done.md` | `.claude/rules/definition-of-done.md` |
| `plans-README.md` | `docs/plans/README.md` |
| `backlog.md` | `docs/backlog.md` |
| `design-README.md` | `docs/design/README.md` |
| `CHANGELOG.md` | `CHANGELOG.md` |

1. Check which project paths already exist. List what you will write and what you will skip.
   An existing file is skipped unless I name it here: $ARGUMENTS
2. Create the missing directories and copy each missing template unchanged, for example with
   `cp -n`. Do not fill the `<placeholders>`, and do not merge into a file that exists.
   Writing under `.claude/` asks for my approval; that is expected, so ask rather than work
   around it.
3. Report, file by file, what you wrote, what you skipped, and the placeholders I still need
   to fill: the build, test and lint commands in `CLAUDE.md` and the Definition of Done first.

Do not stage or commit anything.
