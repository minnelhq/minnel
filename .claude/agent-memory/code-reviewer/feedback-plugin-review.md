---
name: feedback-plugin-review
description: How to review the Minnel plugin (plugin/, .claude-plugin/) and the consistency hook's Check E that pins it to the appendices — test by mutation, not by reading
metadata:
  type: feedback
---

The plugin (`plugin/`, listed by the root `.claude-plugin/marketplace.json`) arrived on branch
`feat/plugin` (first reviewed 2026-11-22/23). Its artefacts are byte-pinned to the appendices by
Check E in `.claude/hooks/docs-consistency.sh` (see [[feedback-hook-script-review]]).

- **Mutation-test Check E in a scratch copy, never by reading the awk.** Copy the tracked files
  (`git ls-files -z | xargs -0 -I{} rsync -R {} <scratch>/`, then `git init` there so the
  check-ignore gate works), mutate one side, pipe a synthetic payload into the hook under `dash`,
  expect exit 2. Cases worth keeping: an extra frontmatter key on the plugin side, a body line on
  either side, a key added after B's `hooks:` block, a blank line inside that block (must stay 0),
  and a skill losing `disable-model-invocation: true`.
- **Normalisers should be one-sided and deny-list shaped.** A normaliser that keeps only an
  allow-listed field, or runs on both sides, hides real drift. When a new normaliser appears, ask
  which side it runs on and what it would hide if the other side changed.
- **Hard-coded skill lists drift.** A per-skill assertion that loops over named skills silently
  skips a newly added skill; prefer a glob over `plugin/skills/*/SKILL.md`. Check the CHANGELOG
  wording ("every plugin skill") against what the loop covers.
- **Path-escape cases for `tests-dir-guard.sh`:** `..` mid-path, trailing `/..`, a path outside
  the project that contains `tests/`, and a sibling prefix (`/proj2/...` with project `/proj`).
  `plugin/scripts/tests/guards.sh` is the place to pin them.
- **Hook command quoting.** `"${CLAUDE_PLUGIN_ROOT}"/scripts/x.sh` works whether Claude Code
  substitutes the variable textually or the shell expands it (simulated both with a spaced path,
  2026-11-23). The same space hazard applies to unquoted `$CLAUDE_PROJECT_DIR/...` in the
  appendix and `.claude/settings.json` examples.
- **Always run** `plugin/scripts/tests/guards.sh`, `claude plugin validate plugin` and
  `claude plugin validate .` when `plugin/` or `.claude-plugin/` changes (the DoD's plugin item).
  The missing-`version` warning is expected until the first release that ships the plugin.
- **Worktree quirk (2026-11-23):** the `.venv` with Zensical lives in the main checkout, not in a
  `.claude/worktrees/*` worktree; run that binary from the worktree (read-only use) for the
  strict build.

**Why:** the plugin's correctness lives in shell and awk that prose review misses; the defects
found so far (normalisers hiding drift, guard path escapes, unquoted plugin root) were only
visible by executing edge cases.
**How to apply:** any diff touching `plugin/`, `.claude-plugin/`, Check E, or a paired appendix.
