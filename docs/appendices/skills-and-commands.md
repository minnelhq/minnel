# Methodology appendices — skills and commands

Drop-in skill and command definitions for the methodology — the example skill and the six ritual commands. Companion to `../methodology.md`; the full index is in this directory's `README.md`.

## Appendix I — example skill

`.claude/skills/add-importer/SKILL.md`

```markdown
---
name: add-importer
description: Scaffold a new data-source importer following project conventions. Use when adding support for a new external source — a new file format, API, or feed.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# Add a data-source importer

When asked to add an importer for a new source:

1. Read an existing importer as the template — match its structure rather than
   inventing a new one.
2. Confirm the source format against a real sample before writing any parsing
   code — never guess field order, encoding, or date locale.
3. Implement the parser against the shared importer interface; do not bypass it.
4. Route every record through the project's normal write and validation path;
   never write to the store directly (see the Invariants in CLAUDE.md).
5. Add tests: happy path, empty input, malformed record.
6. Run the suite and report results.

Out of scope: changing the importer interface itself — raise that as a separate
decision (ADR).
```

## Appendix J — `/plan` command

The plugin ships this as the `plan` skill, `plugin/skills/plan/SKILL.md`.

`.claude/commands/plan.md`

```markdown
---
description: Enter plan mode with the house rules — explore read-only, challenge the approach, then present a plan for approval.
disable-model-invocation: true
---

Enter plan mode for: $ARGUMENTS

Work read-only until I approve a plan. Do not edit files.

1. Explore, read-only. Read the active plan in docs/plans/ and the invariants in CLAUDE.md
   yourself; delegate wider search to the Explore agent, restating any invariant it must respect
   (it skips CLAUDE.md, §1).
2. Decide whether to plan. Skip the ceremony for trivial work: a one-line or single-file change
   with no invariant in play. Say so and stop. Otherwise (a refactor, an architectural choice,
   or anything touching an invariant) continue.
3. Draft the plan: goal, ordered stages, per-stage steps with acceptance criteria, and an
   explicit out-of-scope list.
4. Challenge it before presenting (§2): argue why it might not be worth doing, and find the holes
   in the acceptance criteria. Fold what survives back in.
5. Present through the exit-plan tool. On approval, if the work is multi-stage or won't finish
   this session, write it to docs/plans/<name>.md (Appendix D) and update the active-plan
   pointer (§3) to name it.
```

## Appendix K — `/accept` command

The plugin ships this as the `accept` skill, `plugin/skills/accept/SKILL.md`.

`.claude/commands/accept.md`

```markdown
---
description: Run the Definition of Done against the current diff before calling a change complete.
disable-model-invocation: true
---

Check the current change against the Definition of Done. Do not declare it done until
every item is verified — you will not do this for me unless asked, so I am asking.

1. Run `git diff` (and `git status`) to see exactly what changed.
2. Walk the Definition of Done in `.claude/rules/definition-of-done.md` item by item.
   For each, state the command you ran or the evidence, and PASS / FAIL — not a vibe.
   An item due only before merge, such as the review, is *pending* until the branch
   is ready to merge, not FAIL.
3. Confirm the current stage's acceptance criteria in the active plan (docs/plans/) are met.
4. If anything FAILS or cannot be verified, stop and report it plainly. Do not work
   around it or soften the wording; list exactly what remains.
5. Only when every item passes, or is pending until merge, report the change ready —
   and remind me to advance the plan status (Appendix D) and draft any user-facing
   line into CHANGELOG Unreleased (Appendix H).
```

## Appendix L — `/retro` command

The plugin ships this as the `retro` skill, `plugin/skills/retro/SKILL.md`. Its pruning step runs
the plugin's `scripts/config-audit.sh`, which lists each configuration and memory file's line count
and every path they name that no longer exists. It writes nothing and runs only when the retro asks,
so it costs no context in other sessions. Without the plugin, copy `plugin/scripts/config-audit.sh`
from this repository to `.claude/scripts/config-audit.sh`, keep it executable, and replace
`${CLAUDE_PLUGIN_ROOT}` with `${CLAUDE_PROJECT_DIR}/.claude` in both places below. Claude Code's
`/doctor prompt-audit` (v2.1.283 or later) audits `CLAUDE.md`, rules, skills and commands
without the retro; the retro's sweep adds agent memory and what the finished plan made obsolete.

`.claude/commands/retro.md`

```markdown
---
description: Run a methodology retro — surface recurring friction, propose config changes and prunings.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/config-audit.sh)
disable-model-invocation: true
---

Review what we had to correct repeatedly during this plan. For each recurring issue,
propose the single most durable fix and say where it belongs:

- a CLAUDE.md invariant or convention,
- a `.claude/rules/` entry,
- a PreToolUse/PostToolUse hook,
- a new or amended subagent or skill.

Then prune. Run `${CLAUDE_PLUGIN_ROOT}/scripts/config-audit.sh` and start from its
output: each file's line count and the paths they name that no longer exist. Read the
files it lists (`CLAUDE.md`, `.claude/rules/`, `.claude/agent-memory/` and my
`~/.claude/` rules, among others) and list each entry that:

- the finished plan made obsolete;
- repeats another entry or a Definition of Done item;
- names a file, flag or version that no longer holds;
- contradicts an entry in another scope (no scope takes precedence, so one must go).

Propose a delete, a merge or a rewrite for each.

Output a short list of concrete changes only — no narrative. Do not apply them; I will
review first.
```

## Appendix M — `/release` command

The plugin ships this as the `release` skill, `plugin/skills/release/SKILL.md`.

`.claude/commands/release.md`

```markdown
---
description: Draft unreleased changelog entries from the completed plan and commits; once a release is merged, tag and publish it.
disable-model-invocation: true
---

Prepare a changelog update — draft only, do not edit files until I approve.

If the version given ($ARGUMENTS) already has its heading in the changelog on the
remote's main branch (after `git fetch`) but no tag for that version on the remote
(`git ls-remote --tags origin`), the release is cut but not closed: skip the steps below
and propose the closing steps at the end instead.

1. Read the active plan and the commits since the last release tag. Find the commit
   style and changelog format in the conventions in context: the project's `CLAUDE.md`
   or `.claude/rules/`, else `~/.claude/CLAUDE.md` or `~/.claude/rules/` (the template
   labels them `Commit style:` and `Changelog:`). Where none names one, use its default:
   Conventional Commits for commits, Keep a Changelog for the changelog.
2. Summarise only the user-facing changes, one concise line each.
3. Sort them into the changelog format's categories. For Keep a Changelog: Added,
   Changed, Deprecated, Removed, Fixed, Security. Omit empty categories. With
   Conventional Commits, a commit's type suggests its category (`feat` → Added,
   `fix` → Fixed).
4. Propose these under the unreleased section of the changelog (`## [Unreleased]`
   in Keep a Changelog).
5. If a version was given ($ARGUMENTS), also propose the format's version heading
   over those entries, and keep the unreleased heading, now empty, above it. For Keep
   a Changelog: `## [$ARGUMENTS] - YYYY-MM-DD`, with today's date, below an empty
   `## [Unreleased]`.
6. If a version was given, read the backlog (`docs/backlog.md`) and list any item still
   under that version's heading in Next (or tagged `target: <version>`, the older
   format) at the top of the draft: work meant for this release is still open. If the
   conventions in context name a private-notes path (the template labels it
   `Private/working notes:`) and `git check-ignore` confirms git ignores a file there,
   check any backlog kept in it the same way, and name its items in this chat only. For
   each item, propose deleting its line if the commits show the item has shipped;
   otherwise propose finishing it before the cut, or moving it under a later release's
   heading or Unscheduled (for a tagged item, changing or dropping its tag). Propose
   removing the version's heading once it is empty. If no version was given, suggest one
   from the changes.
   Under Conventional Commits a `feat` makes a minor release, a `fix` a patch, and
   a breaking change a major.

Exclude internal-only changes (refactors, test scaffolding, doc tweaks) unless an
installer would notice. I will curate before anything is committed.

When cutting a release, fold every intended change into the unreleased section and
review it first, then cut once. Don't cut the release commit and amend later additions
into it.

To close a release once its commit is on the main branch, make an annotated tag on the
commit that put it there (for a pull request, the merge or squash commit it made) and
push it: `git tag -a v<version> -m v<version> <commit>`, then
`git push origin v<version>`. If the tag already exists locally, push it rather than
make it again. Use the tag format the conventions name, if they name one. Where the
host publishes releases, publish one from the pushed tag with the version's changelog
section as its notes. On GitHub a single newline in release notes shows as a line break,
so first join each entry onto one line in the notes file. Then run
`gh release create v<version> --verify-tag --notes-file <file holding that section>`.
Pushing the tag and publishing the release change shared state, so run both only with
my go-ahead.
```

## Appendix N — `/wrap` command

The plugin ships this as the `wrap` skill, `plugin/skills/wrap/SKILL.md`.

`.claude/commands/wrap.md`

```markdown
---
description: Close out the session — confirm durable records are current, close a finished plan, then summarise and name it.
disable-model-invocation: true
---

End-of-session wrap. Work in order; do not edit files until I confirm each write.

1. Durable records — check and update:
   - Active plan: advance the current stage, tick completed steps, note deviations.
   - Changelog: draft any user-facing changes in the format the conventions in context
     name (Keep a Changelog under [Unreleased] by default).
   - Decisions: log any made this session in the plan, or propose an ADR if significant.
2. Plan close-out: if the active plan's last stage is finished and every Definition of
   Done item passes, or is pending until merge (such as the review), close the plan.
   - Set its Status line to `**Status:** done (YYYY-MM-DD) — <outcome>`: today's date and
     a one-line outcome, naming any stage that was cut or deviated.
   - Mark every stage `[done]`, giving a cut stage a deviation note that says so, and
     tick each completed step. Then confirm with
     `grep -nE '\[current\]|\[not started\]|^[[:space:]]*[-*] \[ \]' <plan>` that nothing
     is left but skipped steps. A skipped step stays unticked, with a deviation note.
   - Clear the active-plan pointer where CLAUDE.md says it lives (by default the
     backlog's Now section), so it names no plan.
   - Create docs/plans/archive/ if it is missing, then move the file there with `git mv`.
     If the plan was never committed, use `mv` and then `git add` the new path.
3. Retro signal: list anything I had to correct more than once, and propose the single
   durable fix for each (a CLAUDE.md/rules entry, a hook, a subagent, a skill).
4. Pointer summary: one line naming which artefacts this session touched and where
   things landed — not a re-narration of the work.
5. Suggest a session name mirroring the active plan, or the one just closed (e.g.
   add-importer), so the session and plan cross-reference.

Produce all of the above yourself from the session and git history. Do not rely on the
native /recap — it may be unavailable in this environment.
```

## Appendix P — `/triage` command

The plugin ships this as the `triage` skill, `plugin/skills/triage/SKILL.md`.

`.claude/commands/triage.md`

```markdown
---
description: Triage the backlog — check each item still applies, reorder Next, group it by release and show the roadmap.
disable-model-invocation: true
---

Triage the backlog in `docs/backlog.md`. Draft only: do not edit files until I approve.

1. Read the backlog, the active plan, the changelog the conventions in context name
   (`CHANGELOG.md` by default) and the commits since the last release tag. The
   active-plan pointer names the plan; it lives where `CLAUDE.md` says, by default in
   the backlog's Now section. If the conventions, in the project's `CLAUDE.md` or
   `.claude/rules/` or in `~/.claude/`, name a private-notes path (the template labels
   it `Private/working notes:`), and `git check-ignore` confirms git ignores a file
   there, read any backlog kept in it too.
2. Check that each item still applies. Flag any that has shipped (its outcome is in the
   changelog or the commits), is out of date (what it names has moved on), or duplicates
   another; an item the active plan covers is in progress, not stale. Propose deleting a
   shipped item, with an Unreleased line for its user-facing outcome if the changelog
   lacks one; rewriting or parking a stale one; and merging duplicates.
3. Re-tag what has changed (type, value, effort, why now). Propose an order for Next:
   value against effort, with an item that others depend on ahead of them.
4. Propose a grouping for Next under a heading for each release (`### <version>`): the
   items due in the next release or the one after, earliest release first, and the rest
   under `### Unscheduled`. Keep step 3's order within each group, and leave Later
   ungrouped. Suggest each release's version from its items' types: under Conventional
   Commits a `feat` makes a minor release, a `fix` a patch and a breaking change a major.
   A `debt` or `chore` item needs no release of its own unless an installer would notice
   it. Flag a heading that names a version already released. If items carry an inline
   `target: <version>` tag instead, propose moving each under its version's heading and
   dropping the tag.
5. Show the roadmap: the active plan under Now, or none; then Next as grouped, each
   version with its suggested bump and the item types behind it; then Later as one
   undated group. Once the draft is applied, the tracked backlog shows the same grouping
   without the private items.
6. Include private items in the roadmap in this chat only, and group them under the same
   headings where they are kept. The tracked backlog groups tracked items only, and
   names a private blocker in general terms.
7. Present the draft as changes to the backlog, one line of reason each, followed by the
   roadmap. I choose what to apply.
```
