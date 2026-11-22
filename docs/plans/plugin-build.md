# Plan: Build the methodology as a plugin   (approved 2026-11-22)

**Status:** in progress — Stage 2 of 6
<!-- Active-plan pointer: docs/backlog.md "Now (this plan)". Branch: feat/plugin. -->

## Goal
Ship the methodology's drop-in artefacts as an installable Claude Code plugin in `plugin/`,
listed by a marketplace at the repo root, so the document and the plugin ship together under
one version and one CHANGELOG. This is the endpoint `docs/packaging-as-a-plugin.md` names.

Shape of the shipped plugin:

```
plugin/
├── .claude-plugin/plugin.json
├── agents/code-reviewer.md, test-writer.md           # Appendices A, B
├── skills/plan, accept, retro, release, wrap/SKILL.md # J–N, disable-model-invocation
├── skills/scaffold/SKILL.md + templates/              # D–H, CLAUDE.md template
├── hooks/hooks.json
└── scripts/bash-guard.sh, git-guard.sh, tests-dir-guard.sh   # C, B's guard
```

## Out of scope
- This repo's own `.claude/` setup, meaning the consistency hook, the `add-section` and
  `close-plan` skills, and the tuned reviewer. It stays at project level and isn't moved to
  depend on the plugin.
- Appendix I's `add-importer` and the `format-and-test.sh` hook. Both are illustrative and
  specific to one project.
- Appendix O, the security checklist. It's a judgement list, not an action, so it stays a doc
  and the packaging doc points to it.
- `claude plugin eval` suites. The rituals run only when the user invokes them, so triggering
  accuracy, which evals measure, matters little. Revisit if model-invoked skills ship.
- Renumbering or re-lettering anything. No new § or appendix letter.
- Raising the version, cutting a release, trademark or domain registration, and submitting to
  Anthropic's plugin directory.
- Changing §10's advice that rituals are commands. Flagged as a follow-up, not acted on here.

---

## Stage 1 — Skeleton   [done]
- [x] `plugin/.claude-plugin/plugin.json`: placeholder `name`, `description`, `author`,
      `license: Apache-2.0`, `repository`. No `version` (see Decisions).
- [x] Root `.claude-plugin/marketplace.json` with `name`, `owner` and
      `plugins: [{name, source: "./plugin"}]`.
- [x] `CLAUDE.md` Layout: one line for `plugin/` and `.claude-plugin/`.
- [x] Add the verified plugin mechanics (Decisions) to the project memory on version-gated claims.
- Acceptance: `claude plugin validate plugin` and `claude plugin validate .` pass, with the
  missing `version` as the only allowed warning. In a scratch repo,
  `claude --plugin-dir <repo>/plugin` starts and `/plugin` lists the plugin.

## Stage 2 — Agents   [current]
- [ ] `plugin/agents/code-reviewer.md`, from Appendix A (the generic copy, not this repo's
      tuned one).
- [ ] `plugin/agents/test-writer.md`, from Appendix B without its frontmatter `hooks:` block.
- Acceptance: in a scratch repo with a small diff, `/agents` lists both as `methodology:<name>`.
  The code-reviewer returns a review grouped by priority with no file edits. test-writer writes
  a file under `tests/`.

## Stage 3 — Hooks   [not started]
- [ ] `plugin/scripts/bash-guard.sh` and `git-guard.sh`, from Appendix C. git-guard skips only
      its commit/push block when a per-project env var is `0`. The env var's name gets the
      plugin prefix chosen in Stage 6. A project sets it in its `.claude/settings.json` `env`.
- [ ] `plugin/scripts/tests-dir-guard.sh` acts only when `agent_type` ends in `:test-writer`,
      so the Stage 6 rename doesn't touch it. It blocks a `Write` or `Edit` outside the test
      directories.
- [ ] `plugin/hooks/hooks.json` wires the three scripts on `PreToolUse` (`Bash` and
      `Write|Edit`) through `${CLAUDE_PLUGIN_ROOT}/scripts/`.
- [ ] A table-driven check script in `plugin/scripts/tests/` that can be rerun.
- Acceptance:
  - The check script feeds sample tool-call JSON to each guard.
    - Exit 2 on `git add -A`, `git add --all`, `git add .`, `git commit -m x`, `git push`,
      `rm -rf /tmp/x`, and a test-writer `Write` to `src/a.py`.
    - Exit 0 on `git add docs/x.md`, `git status`, a main-session `Write` to `src/a.py`, and a
      test-writer `Write` to `tests/test_a.py`.
    - With the opt-out set, `git commit` exits 0 and `git add -A` still exits 2.
  - Live in a scratch repo, Claude Code refuses `git add -A`.

## Stage 4 — Rituals and project scaffolding   [not started]
- [ ] `plugin/skills/{plan,accept,retro,release,wrap}/SKILL.md`, from Appendices J–N with
      `disable-model-invocation: true`. They point at project files only (`docs/plans/`,
      `.claude/rules/definition-of-done.md`, `CHANGELOG.md`), never at plugin paths.
- [ ] `plugin/skills/scaffold/` writes the project-level pieces a plugin can't bundle:
  - `.claude/rules/definition-of-done.md` (E)
  - `docs/plans/` (D)
  - `docs/backlog.md` (F)
  - `docs/design/` with an ADR skeleton (G)
  - `CHANGELOG.md` (H)
  - `CLAUDE.md` from `templates/CLAUDE.template.md`

  It lists what it will write, skips any file that already exists unless told otherwise, and
  fills no placeholders by guessing.
- Acceptance:
  - In an empty scratch repo, `/methodology:scaffold` writes exactly those files.
  - A second run writes nothing.
  - `/methodology:accept` then walks the written Definition of Done item by item.
  - Each of the five rituals appears in the `/` menu, and none is auto-invoked during an
    ordinary request.

## Stage 5 — Keep appendices and plugin in step; docs   [not started]
- [ ] Check E in `.claude/hooks/docs-consistency.sh`.
  - It applies to an appendix fenced block that follows a backticked project path, such as
    `` `.claude/agents/code-reviewer.md` ``.
  - A table in the script maps the block to its plugin file.
  - It normalises the listed intended differences before comparing: hook paths, B's dropped
    `hooks:` block, the opt-out lines, and the skill frontmatter.
  - On a mismatch it names the appendix and the file.
  - It runs on edits to either side.
- [ ] `docs/packaging-as-a-plugin.md`:
  - an "Install this plugin" section, with commands that need no prompts
  - the tree and mapping table aligned with what ships (rituals as skills, why, and the
    scaffold)
  - the "build your own" rationale kept
- [ ] Appendices A–C and E–N: one line each naming the plugin file that ships the artefact.
- [ ] Update the "Using it" and "Status" sections of `README.md`, and the pointer in
      `docs/index.md`.
- [ ] Add Added entries under `[Unreleased]` in `CHANGELOG.md`, in the same commits as the
      changes they describe.
- Acceptance:
  - Check E flags a deliberate one-word drift in Appendix J and passes once it's reverted.
  - `zensical build --strict` builds cleanly.
  - The consistency hook passes on every doc this stage touches, and every § and appendix
    reference touched still resolves.

## Stage 6 — Christen and publish   [not started]
- [ ] The maintainer chooses the public name. Rename the placeholder across `plugin.json`,
      `marketplace.json`, the opt-out env var, the docs, README and CHANGELOG. Then re-run
      Check E and the Stage 3 checks.
- [ ] After the push, run
      `claude plugin marketplace add tcrossland/claude-code-methodology` and
      `claude plugin install …` in a scratch repo. Confirm every component appears under the new
      namespace and that a guard fires.
- [ ] Delete the naming item from the backlog.
- Acceptance: a clean install from GitHub passes the Stage 2–4 checks under the new name.

---

## Deviations
- 2026-11-22, Stage 1 — acceptance checked with `claude --plugin-dir ./plugin plugin details methodology`
  (prints the component inventory without a session) instead of `/plugin` in a scratch repo.

## Decisions
- 2026-11-22 — The plugin lives in `plugin/`, and a root `.claude-plugin/marketplace.json`
  lists it with `"source": "./plugin"`. That keeps the document and the plugin under one version
  and one CHANGELOG.
- 2026-11-22 — It's built under the placeholder name `methodology`. The public name is chosen
  in Stage 6, before the first publish. Renaming before publishing costs nothing; renaming
  after does.
- 2026-11-22 — The plugin files are the source. The appendices keep their embedded copies so
  they stay self-contained to read, and Check E catches drift.
- 2026-11-22 — The git guard ships on, and a project can turn off the commit/push block with an
  env var. The block on blanket staging stays on in every project.
- 2026-11-22 — `plugin.json` gets no `version` during the build. The release that first ships
  the plugin sets it to the CHANGELOG version, and the two stay equal after that.
- 2026-11-22 — Rituals ship as skills with `disable-model-invocation: true`, not as commands.
  The plugin docs call `commands/` "the older format" and prefer `skills/` for new plugins. The
  flag keeps the user deciding when a ritual runs, which is the property §10 wants from
  commands. The appendices still show `.claude/commands/` for use without the plugin.
- 2026-11-22 — Plugin mechanics, checked against code.claude.com (the docs cite up to v2.1.330;
  the installed CLI is v2.1.273):
  - In `plugin.json`, only `name` is required, and `validate` warns when `version`,
    `description` or `author` is missing.
  - `rules/` is not a plugin component, and a plugin's `CLAUDE.md` is not loaded.
  - Plugin agents ignore `hooks`, `mcpServers` and `permissionMode` in frontmatter.
  - When a call comes from a subagent, `PreToolUse` input carries `agent_type`, in the form
    `<plugin>:<agent>`.
  - Hook commands get `${CLAUDE_PLUGIN_ROOT}` and `$CLAUDE_PROJECT_DIR`, and `hooks/hooks.json`
    needs a top-level `"hooks"` key.
  - A plugin-root `settings.json` is undocumented, so the plugin doesn't rely on one.
- 2026-11-22 — Challenge: test-writer, bash-guard and the scaffold haven't been proven in real
  use the way the reviewer, the Definition of Done, the git guard and the five rituals have.
  They ship as the appendices give them, and the packaging doc says so.
