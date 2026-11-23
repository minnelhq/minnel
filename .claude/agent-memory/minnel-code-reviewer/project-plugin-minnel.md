---
name: project-plugin-minnel
description: The shipped plugin (Minnel, in plugin/) and the consistency hook's Check E that pins it to the appendices — what to check and the blind spots found
metadata:
  type: project
---

The methodology ships as a plugin named **Minnel** in `plugin/`, listed by a root
`.claude-plugin/marketplace.json` (install `minnel@minnel`). Built on branch `feat/plugin`
(plan archived as `docs/plans/archive/plugin-build.md`, first reviewed 2026-11-23). The plugin
files are the source; the appendices keep embedded copies, and Check E in
`.claude/hooks/docs-consistency.sh` flags drift between each pair (A, B, both C guards, D–H, J–N,
and `templates/CLAUDE.template.md` vs the scaffold's copy).

**Why:** document and plugin ship under one version and one CHANGELOG, so drift between an
appendix and its plugin file is now a defect class like a dangling §N.

**How to apply:**
- Plugin skills and agents are namespaced: a skill runs as `/minnel:<name>`, never bare
  `/<name>` (skills docs, "plugin skills are namespaced as /plugin-name:skill-name", checked
  2026-11-23). Grep tracked prose for bare `/scaffold`, `/plan` etc. used to mean the *plugin*
  skill; the first review found both forms mixed.
- Check E normalisers can hide drift. The first review (2026-11-23) found three gaps: a field
  added after `hooks:` in Appendix B, an `allowed-tools` line added to an appendix command, and a
  plugin skill losing `disable-model-invocation: true` all passed. Fixed the same day:
  `drop_hooks` ends at the first unindented line, `skill_fm` became `drop_skill_keys` (a
  plugin-side deny-list), and every skill's frontmatter must carry the flag. Re-test after any
  normaliser edit. Later on 2026-11-23 the J–N appendix frontmatters gained
  `disable-model-invocation: true` and `drop_skill_keys` stopped stripping it, so the flag is
  compared within each J–N pair as well as by the every-skill check; if someone re-adds it to the
  deny-list, an appendix losing the flag would pass again. Appendix H's example version headings are not compared either (hook header,
  limitation 4; confirmed by mutation 2026-11-23), so a heading-format change there needs a manual
  grep. Prose around the D and G skeletons in the scaffold templates is still not
  compared (a listed limitation).
- Mutation-test Check E in a `git archive <branch> | tar -x` copy in the scratchpad, running the
  hook with `CLAUDE_PROJECT_DIR` set to that copy; never mutate the shared checkout.
- With `plugin/scripts/tests/guards.sh` and `claude plugin validate` in the repo, "no build or
  test step" carriers (CLAUDE.md intro, DoD preamble and its HTML comment, README Dogfooding) go
  stale. Reconciled 2026-11-23, with a DoD plugin item; check new prose doesn't reintroduce them.
- `hooks.json` command paths: the plugins reference quotes the root
  (`"\"${CLAUDE_PLUGIN_ROOT}\"/scripts/x.sh"`); an unquoted root breaks on a path with a space
  and the guard then fails open silently.

- ADR 0004 (`docs/design/0004-ship-the-plugin-from-this-repo.md`, drafted 2026-11-23) records
  the plugin decisions; the plan's Decisions section is its source. Its first draft miscounted
  the PAIRS rows (said 15 appendix pairs plus the template; it was 14 plus the template). Count
  the heredoc rows yourself whenever prose states a pair count, and prefer prose with no count,
  since every new row strands one.
- "Has run on this repository" claims (packaging doc, "Install this plugin"; ADR 0004
  Consequences; README Dogfooding) must match what `.claude/settings.json` wires, not what the
  plugin ships. From 2026-11-23 (branch reconcile-claude-minnel-config) `.claude/settings.json`
  enables `minnel@minnel` from the GitHub marketplace, so the rituals and both guards run here;
  re-check the packaging doc's and ADR 0004's "less use" lists as that use accrues. The
  pieces-with-less-use list lives in two places; a change to one strands the other.
- Dogfooding caveat: a `github` marketplace source runs the published default branch, not the
  worktree's `plugin/`. A branch that edits a plugin skill is not exercised by `/minnel:<skill>`
  here until merged and the marketplace refreshed. Don't accept "ran it here" as evidence for a
  plugin edit on the same branch.
- Since 2026-11-23 the repo has no reviewer of its own: you are `minnel:code-reviewer`, and this
  memory moved from `.claude/agent-memory/code-reviewer/` to `minnel-code-reviewer/` (the folder
  Claude Code uses for the namespaced agent; observed, not documented). The repo-only checks the
  old tailored prompt carried (hook-script safety, CI least privilege, the Zensical and plugin
  commands) are Definition of Done items now, so read the DoD every review. Until the Appendix A
  step that says so is merged and the marketplace refreshed, the installed copy lacks it.
- Claims in prose that go beyond the plan's recorded mechanics (e.g. how an unversioned plugin
  updates) need their own dated source; the plan's "Plugin mechanics" decision is the verified set.

See [[feedback-hook-script-review]], [[project-plugin-rules-claim]], [[feedback-recurring-defects]].
