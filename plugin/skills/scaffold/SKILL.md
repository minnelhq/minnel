---
name: scaffold
description: Set up the project files the methodology relies on, which a plugin cannot ship itself — CLAUDE.md, the Definition of Done rule, docs/plans/, docs/backlog.md, docs/design/ and CHANGELOG.md — filled in with the project's conventions, and optionally the guard settings and a commit-msg hook.
argument-hint: "[files to overwrite]"
disable-model-invocation: true
---

Set up this project for the methodology, filled in with its conventions. The templates are in
`${CLAUDE_SKILL_DIR}/templates/`.

| Template | Project path |
|---|---|
| `CLAUDE.md` | `CLAUDE.md` |
| `definition-of-done.md` | `.claude/rules/definition-of-done.md` |
| `plans-README.md` | `docs/plans/README.md` |
| `backlog.md` | `docs/backlog.md` |
| `design-README.md` | `docs/design/README.md` |
| `CHANGELOG.md` | `CHANGELOG.md` |
| `commit-msg` | `.githooks/commit-msg`, only if I ask for the hook in step 3 |

1. Check which project paths already exist. An existing file is skipped unless I name it here:
   $ARGUMENTS
2. Read what the project already shows, to propose answers rather than ask from nothing:
   - build, test, lint and run commands from its manifests and scripts (`package.json`,
     `pyproject.toml`, `Makefile`, `Cargo.toml`, `go.mod` and the like);
   - the commit style from `git log --oneline -20`;
   - the changelog's format, path and unreleased heading from an existing changelog;
   - a notes folder named in `.gitignore`, confirmed with `git check-ignore`;
   - whether this repository sets `core.hooksPath` (`git config --local core.hooksPath`), and
     whether a global one is set; whether a `commit-msg` hook already exists there or in
     `.git/hooks/`; and whether `.claude/settings.json` exists.
3. Ask me once, in one message: a numbered list, each question with its proposed answer, so I
   can accept them all or change some. Propose what step 2 found, else the default given here.
   1. The project's name, and one or two sentences on what it is and for whom.
   2. The build, test, lint and run commands.
   3. Language, spelling and tone for prose and user-facing strings. No default: propose what
      the existing docs use.
   4. The date format (default: ISO `YYYY-MM-DD`).
   5. The commit style (default: Conventional Commits, imperative mood, one concern per commit).
   6. The changelog format (default: Keep a Changelog with SemVer, `CHANGELOG.md` at the root).
   7. A private-notes path, gitignored, that Claude reads but never commits; or none.
   8. Where the active-plan pointer lives (default: the backlog's Now section).
   9. The review gate: no second reviewer, or a human review after the subagent's; and which
      branches count as trivial and skip review, if any.
   10. Each guard: allow, ask or block. Defaults: blanket staging block, commits allow, pushes
       ask, the bash guard (forced recursive `rm`, force push, `DROP TABLE`) block.
   11. Whether to install the `commit-msg` hook (Appendix Q), and if so whether it checks that
       a `feat` or `fix` commit adds a changelog line (default: no hook; with the hook, the
       check is on when the commit style has `feat` and `fix` types and the changelog has an
       unreleased heading).
4. Write each missing file from its template, filling the placeholders my answers cover:
   - `CLAUDE.md`: the name and description, the Commands block, the Conventions lines
     (language, spelling, tone and date format on the first; commit style; changelog; the
     private-notes path, or delete that line), the Active plan line to keep, the review
     sentence to keep, and the trivial branches (or delete that placeholder).
   - The Definition of Done: the build, test and lint commands. Delete an item whose command I
     said the project has none of.
   - `docs/backlog.md`: replace the example items with `- (none — no active plan)` under Now
     and `- (none)` under Unscheduled, Later and Parked, and drop the example `### <version>`
     heading.
   - `CHANGELOG.md`: write it only for Keep a Changelog. For another format, skip it and say so.
   - `docs/plans/README.md` and `docs/design/README.md`: copy them unchanged.
   Leave every placeholder my answers don't cover, such as the invariants and the architecture
   pointer. Do not merge into a file that exists. Writing under `.claude/` asks for my approval;
   that is expected, so ask rather than work around it.
5. Guards: for each guard I set away from its default, add its setting under `env` in
   `.claude/settings.json`: `MINNEL_GIT_GUARD_STAGING`, `MINNEL_GIT_GUARD_COMMITS`,
   `MINNEL_GIT_GUARD_PUSHES` or `MINNEL_BASH_GUARD`, set to `"allow"`, `"ask"` or `"block"`. If
   the file doesn't exist, create it with only that `env` block. If it exists, show me the edit
   and apply it once I approve; keep its other keys as they are. Write nothing for defaults.
6. Hook, only if I asked for it. Choose where it goes:
   - If this repository sets its own `core.hooksPath` to a tracked directory inside the
     repository, use that directory. If that directory is gitignored (`git check-ignore`) or
     outside the repository, as a hook manager's generated directory is, stop and ask me. For
     Husky, the hook goes in `.husky/commit-msg`.
   - Otherwise use `.githooks/`.
   - Never use a global hooks directory: the hook would run in every repository.
   - If a `commit-msg` already exists where it would go, skip it unless I named it, and say so.

   Copy `commit-msg` there and make it executable. Then set the settings at its top:
   - `CHANGELOG` to the changelog's path and `UNRELEASED` to its unreleased heading as written,
     from my answer to question 6 or the existing file.
   - `REQUIRE_CHANGELOG=no` if I turned the check off, or if the project has no changelog with
     an unreleased heading. Say which.
   - For a commit style other than Conventional Commits, `SUBJECT` to a pattern for that style,
     and `REQUIRE_CHANGELOG=no` unless the style has `feat` and `fix` types. Show me both.

   Don't run `git config` yourself. If the repository sets no `core.hooksPath`, give me
   `git config core.hooksPath .githooks` to run, and say that for this repository it replaces
   `.git/hooks` and any global hooks path, so hooks from either need moving into `.githooks/`.
7. Report, file by file, what you wrote, what you skipped, and the placeholders I still need to
   fill, the invariants first.

Do not stage or commit anything.
