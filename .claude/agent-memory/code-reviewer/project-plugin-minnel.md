---
name: project-plugin-minnel
description: The shipped plugin (Minnel, in plugin/) and the consistency hook's Check E that pins it to the appendices — what to check and the blind spots found
metadata:
  type: project
---

The methodology ships as a plugin named **Minnel** in `plugin/`, listed by a root
`.claude-plugin/marketplace.json` (install `minnel@minnel`). Built on branch `feat/plugin`
(plan `docs/plans/plugin-build.md`, first reviewed 2026-11-23). The plugin files are the source;
the appendices keep embedded copies, and Check E in `.claude/hooks/docs-consistency.sh` flags
drift between each pair (A, B, both C guards, D–H, J–N, and `templates/CLAUDE.template.md` vs the
scaffold's copy).

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
  normaliser edit. Prose around the D and G skeletons in the scaffold templates is still not
  compared (a listed limitation).
- Mutation-test Check E in a `git archive <branch> | tar -x` copy in the scratchpad, running the
  hook with `CLAUDE_PROJECT_DIR` set to that copy; never mutate the shared checkout.
- With `plugin/scripts/tests/guards.sh` and `claude plugin validate` in the repo, "no build or
  test step" carriers (CLAUDE.md intro, DoD preamble and its HTML comment, README Dogfooding) go
  stale. Reconciled 2026-11-23, with a DoD plugin item; check new prose doesn't reintroduce them.
- `hooks.json` command paths: the plugins reference quotes the root
  (`"\"${CLAUDE_PLUGIN_ROOT}\"/scripts/x.sh"`); an unquoted root breaks on a path with a space
  and the guard then fails open silently.

See [[feedback-hook-script-review]], [[project-plugin-rules-claim]], [[feedback-recurring-defects]].
