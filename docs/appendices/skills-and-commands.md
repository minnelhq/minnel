# Methodology appendices — skills and commands

Drop-in skill and command definitions for the methodology — the example skill and the five ritual commands. Companion to `../methodology.md`; the full index is in this directory's `README.md`.

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

The plugin ships this as the `retro` skill, `plugin/skills/retro/SKILL.md`.

`.claude/commands/retro.md`

```markdown
---
description: Run a methodology retro — surface recurring friction and propose config changes.
disable-model-invocation: true
---

Review what we had to correct repeatedly during this plan. For each recurring issue,
propose the single most durable fix and say where it belongs:

- a CLAUDE.md invariant or convention,
- a `.claude/rules/` entry,
- a PreToolUse/PostToolUse hook,
- a new or amended subagent or skill.

Output a short list of concrete changes only — no narrative. Do not apply them; I will
review first.
```

## Appendix M — `/release` command

The plugin ships this as the `release` skill, `plugin/skills/release/SKILL.md`.

`.claude/commands/release.md`

```markdown
---
description: Draft unreleased changelog entries from the completed plan and commits.
disable-model-invocation: true
---

Prepare a changelog update — draft only, do not edit files until I approve.

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
   in place of the unreleased one. For Keep a Changelog:
   `## [$ARGUMENTS] - YYYY-MM-DD`, with today's date.

Exclude internal-only changes (refactors, test scaffolding, doc tweaks) unless an
installer would notice. I will curate before anything is committed.

When cutting a release, fold every intended change into the unreleased section and
review it first, then cut once. Don't cut the release commit and amend later additions
into it.
```

## Appendix N — `/wrap` command

The plugin ships this as the `wrap` skill, `plugin/skills/wrap/SKILL.md`.

`.claude/commands/wrap.md`

```markdown
---
description: Close out the session — confirm durable records are current, then summarise and name it.
disable-model-invocation: true
---

End-of-session wrap. Work in order; do not edit files until I confirm each write.

1. Durable records — check and update:
   - Active plan: advance the current stage, tick completed steps, note deviations.
   - Changelog: draft any user-facing changes in the format the conventions in context
     name (Keep a Changelog under [Unreleased] by default).
   - Decisions: log any made this session in the plan, or propose an ADR if significant.
2. Retro signal: list anything I had to correct more than once, and propose the single
   durable fix for each (a CLAUDE.md/rules entry, a hook, a subagent, a skill).
3. Pointer summary: one line naming which artefacts this session touched and where
   things landed — not a re-narration of the work.
4. Suggest a session name mirroring the active plan (e.g. add-importer), so the session
   and plan cross-reference.

Produce all of the above yourself from the session and git history. Do not rely on the
native /recap — it may be unavailable in this environment.
```
