# Plan: Release 0.8.0, the bootstrap with its guard and hook settings   (approved 2026-11-25)

**Status:** Stage 1 done; Stage 2 of 6 next.

## Goal
`/minnel:scaffold` asks for the adopter's conventions and writes the project files with those
answers filled in. The bootstrap can switch each guard to allow, ask or block, and can install
a `commit-msg` hook, described in a new Appendix Q. `/release` leaves an empty Unreleased
section after a cut.

Why: the scaffold copies templates and leaves every `<placeholder>` for the adopter. Two
backlog items build on a bootstrap that asks instead. The guards that have no setting get one,
and a git hook enforces the commit style the bootstrap records. The `/release` wording fix
rides along. The work changes plugin scripts and the template pairs that Check E compares. It
also changes the appendix lettering with a new Appendix Q.

Order: the fix first, because it's independent. Then the guard settings and the hook, so the
bootstrap has something to offer. The bootstrap comes last of the features.

## Out of scope
- Blocking `git commit --no-verify` in `bash-guard`, which would stop Claude bypassing the hook.
  It goes to the backlog as its own item.
- Renaming `/minnel:scaffold`: installs and docs use the name.
- Installing the `commit-msg` hook in this repository.
- Settings for `tests-dir-guard`: it is scoped to `test-writer` already.
- Changing the guards' default from on. ADR 0004 stands, and the bootstrap offers the switch.
- Merging into an existing project file: the scaffold still skips one unless it's named.
- Commit-style patterns other than Conventional Commits, beyond a documented setting to adapt.
- Cutting 0.8.0 before the maintainer says so (Stage 6).

---

## Stage 1 — `/release` keeps an empty Unreleased   [done]
- [x] Appendix M step 5 and `plugin/skills/release/SKILL.md`: propose the version heading below
      `## [Unreleased]`, moving its entries under the new heading and leaving the Unreleased
      heading empty on top, as Keep a Changelog and §8 do. Change both copies together.
- [x] `CHANGELOG.md` Fixed line; delete the backlog item in the same commit.
- Acceptance: Check E passes for Appendix M; `git grep -n 'in place of the unreleased'` finds
  nothing outside `docs/plans/archive`; Appendix H and §8 don't contradict the new wording.

## Stage 2 — Settings for every guard   [todo]
- [ ] Recheck the Claude Code hooks and plugin docs for a way to turn off one plugin's hooks (the
      backlog last checked on 2026-11-23). If one exists, document it beside the settings.
- [ ] `git-guard.sh`: the blanket-staging and `commit -a` blocks read a `STAGING` decision
      (default `block`), with `MINNEL_GIT_GUARD_STAGING` overriding it inside the plugin
      settings block. Reuse `strictest()` and the existing ask JSON.
- [ ] `bash-guard.sh`: its `block()` honours a `BASH_GUARD` decision (default `block`), with
      `MINNEL_BASH_GUARD` in a new `# Plugin settings:` block. An unknown value counts as block,
      as in the git guard.
- [ ] Appendix C copies take the same logic with the defaults hard-coded; add
      `drop_plugin_settings` to the bash-guard pair in `.claude/hooks/docs-consistency.sh`.
- [ ] `plugin/scripts/tests/guards.sh`: unset the new variables at the top; `check` cases for
      allow, ask, block and an unknown value on each setting.
- [ ] Docs: `docs/plugin.md` (the guards paragraph), §9's git-guard sentence, `plugin/README.md`,
      the README's "Three guards" entry in "What you get", `docs/appendices/hooks.md` intro, an
      amendment to ADR 0004's "Guards on by default". `CHANGELOG.md` Added; trim the backlog
      item to what Stage 4 still owes.
- Acceptance: `plugin/scripts/tests/all-awks.sh` passes under each installed awk (a `skip` is
  reported as unchecked); `claude plugin validate plugin` and `claude plugin validate .` pass;
  Check E passes for all three Appendix C pairs; removing either setting fails a test.

## Stage 3 — Appendix Q, a `commit-msg` hook   [todo]
- [ ] Add Appendix Q to `docs/appendices/hooks.md` with the `add-section` skill, so every
      "A–P" range becomes "A–Q": this repo's `CLAUDE.md`, the Definition of Done,
      `CONTRIBUTING.md`, `docs/appendices/README.md`, the methodology and `docs/plugin.md`.
- [ ] The hook script, shipped as `plugin/skills/scaffold/templates/commit-msg` and paired whole
      with Appendix Q's fenced block in Check E. Settings at its top: the subject pattern
      (Conventional Commits by default), the `CHANGELOG` path, and `REQUIRE_CHANGELOG` (yes or
      no).
      - It rejects a subject that doesn't match, naming the pattern.
      - It lets through merge commits, git's own revert subjects, and `fixup!`, `squash!` and
        `amend!` commits.
      - For `feat` or `fix` (with any scope or `!`), it requires the staged diff to add a line
        inside the changelog's Unreleased section. A missing changelog file fails with a message
        naming the setting.
      - `git commit --amend` passes when the commit being amended already made that change.
- [ ] `plugin/scripts/tests/commit-msg.sh` drives the hook in throwaway repos, one case per rule
      above. Add it to `.github/workflows/guards.yml`, the Definition of Done's plugin item and
      `CONTRIBUTING.md`'s "Checks".
- [ ] Docs: §6 explains that a git hook also catches human commits, while a Claude Code hook sees
      only Claude's calls, and points to Appendix Q. §8 gets one sentence on the changelog check.
      Appendix Q says how it sits with the git guard: the guard decides before the call, the hook
      checks the message after, and `--no-verify` bypasses the hook. Add a `docs/plugin.md`
      mapping row and `CHANGELOG.md` Added lines.
- Acceptance: `commit-msg.sh` passes, and each rule has a case that fails when the rule is
  removed; Check E passes for the Q pair; the consistency hook finds no dangling §N or letter;
  `zensical build --strict` passes.

## Stage 4 — `/minnel:scaffold` becomes a bootstrap   [todo]
- [ ] Rewrite `plugin/skills/scaffold/SKILL.md`, keeping `disable-model-invocation: true` and the
      `$ARGUMENTS` overwrite list:
  1. Check which project paths exist, as now.
  2. Read what the project already shows to propose answers:
     - build, test and lint commands from its manifests;
     - commit style from `git log`;
     - changelog format from an existing `CHANGELOG.md`;
     - an existing gitignored notes folder.
  3. Ask once, with every question carrying a default or a detected value:
     - project name and one-line purpose;
     - commands;
     - language and spelling;
     - date format (ISO by default);
     - commit style (Conventional Commits);
     - changelog format (Keep a Changelog);
     - private-notes path, or none;
     - where the active-plan pointer lives (the backlog by default);
     - the review gate, and which branches count as trivial;
     - each guard: allow, ask or block;
     - whether to install the `commit-msg` hook, and whether to turn on its changelog check.
  4. Write each missing file from its template, filling the placeholders the answers cover and
     leaving the rest (invariants, architecture) for the adopter. That covers the `CLAUDE.md`
     Conventions and Commands blocks, its Active plan line and its review sentence, and the
     Definition of Done's commands. Write `CHANGELOG.md` only for Keep a Changelog, and report
     that another format needs its own.
  5. Write non-default guard choices as `env` in `.claude/settings.json`. If that file exists,
     show the edit and apply it on approval.
  6. When asked, copy the hook to `.githooks/commit-msg` (executable). If `core.hooksPath` is
     already set, copy it there instead. Otherwise give the `git config core.hooksPath .githooks`
     command and say that it replaces `.git/hooks`.
  7. Report file by file what was written, skipped and left to fill.
- [ ] Templates stay as they are: Check E pairs them with Appendices D–H and the root template.
- [ ] Docs:
  - `docs/plugin.md`: "Install this plugin" steps 1–2.
  - `README.md`: the quick start's "fill in the placeholders it reports" line and the "Project
    files" entry.
  - `docs/index.md`: the same quick-start line.
  - `plugin/README.md`.
  - ADR 0004's "Project files by scaffold", if its claim changes.
  - `CHANGELOG.md`: a Changed line. Delete the backlog item.
- Acceptance: in a throwaway git repo, with `--plugin-dir` pointing at this branch's `plugin/`,
  run the skill once with the defaults and once with non-default answers. If it can't run
  non-interactively, the maintainer runs it. Then check:
  - answered placeholders are filled and the rest are reported;
  - an existing file is untouched;
  - `.claude/settings.json` gains `env` only for non-default guards;
  - the hook lands executable and rejects a bad subject.

  `claude plugin validate` passes.

## Stage 5 — Records and review   [todo]
- [ ] Every user-facing change has its `[Unreleased]` line, written in the commit that made it.
      The four 0.8.0 backlog items are gone and `### 0.8.0` is removed. The `--no-verify` item
      is added under Unscheduled.
- [ ] `zensical build --strict`; `minnel:code-reviewer` on the branch diff; `/minnel:accept`.
- Acceptance: no Critical findings; every Definition of Done item has evidence.

## Stage 6 — Cut 0.8.0 (on the maintainer's word)   [todo]
- [ ] `/minnel:release 0.8.0`: the version heading, and `plugin.json` `version` to 0.8.0, both in
      the release commit. After the merge, the annotated tag and the GitHub release, each with
      the maintainer's go-ahead.
- Acceptance: the Definition of Done's release item, with tag and release *pending* until merge.

---

## Deviations
(none yet)

## Decisions
- 2026-11-25 — The `commit-msg` hook gets its own Appendix Q in `hooks.md`, not a part of
  Appendix C, because a git hook is a different kind of hook from a Claude Code hook.
- 2026-11-25 — Each new guard setting takes allow, ask or block, as the git guard's do, with the
  current behaviour as default, because one shape for every setting is easier to learn and
  ADR 0004 keeps the guards on.
- 2026-11-25 — The hook installs through `.githooks/` and `core.hooksPath`, which the adopter
  sets, because the scaffold shouldn't change git config unasked.
