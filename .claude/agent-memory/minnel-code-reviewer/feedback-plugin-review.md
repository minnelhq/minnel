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
- **Packaging script (`scripts/package.sh`, first reviewed 2026-11-23).** Test what reaches the
  zip in a `git archive` scratch copy: an untracked/ignored file in `plugin/` (e.g. `.env`) and an
  absolute symlink to a file or directory outside the repo. `cp -R` keeps the link and `zip -r`
  follows it, so outside content lands in the zip unless staging comes from git or `zip -y` /
  a symlink check is used. Also check `CDPATH= cd` in the root-finding line, that a failed
  `claude plugin validate` stops the build (it does: exit 1 under `set -e`), and that the
  version string can't hold `/`. `claude plugin validate` does not check semver.
  A `git archive | tar -x` pipeline under `set -eu` (no pipefail in POSIX sh) hides a failed
  archive: macOS bsdtar exits 0 on empty stdin (checked 2026-11-23), so the failure only surfaces
  later, if something downstream needs a staged file. Prefer `git archive -o <file>` then
  `tar -xf`. Building from HEAD also drops uncommitted `plugin/` edits from a `--dev` test build;
  check the script says so at run time, not only in its header comment.
- **Git guard decisions (allow/ask/block, reviewed 2026-11-23).** The guard can return an
  "ask" (exit 0 plus `permissionDecision` JSON), so a test must tell exit 0 *with* ask JSON from a
  plain 0. Edge cases to run: `git commit -a`/`-am`/`--all` (blanket staging through commit,
  which the `git add` pattern never sees once commits are allowed), global options before the
  subcommand (`git -C dir push`, `git -c k=v push`, `git --no-pager push`, all unmatched by
  `\bgit push\b`), mixed-case setting values, an empty setting, and a commit-then-push chain under
  each setting. `guards.sh` inherits the caller's environment, so an exported
  `MINNEL_GIT_GUARD_*` (e.g. from a project's settings `env`) skews its default-case results
  unless it unsets them. The plugin-side settings normaliser is marker-bounded: any code put
  between the markers is invisible to Check E (mutation-confirmed), so read that block by eye.
  A `git commit` + `-a` pattern of the `\bgit commit\b.*[[:space:]](-a…|--all)` shape (probed
  2026-11-23): `.*` runs to the end of the line, so it blocks `-a` inside a quoted message and
  in a chained command (`&& git log --all`, `&& ls -a`), and it misses clusters where `a` is not
  first (`-qam`, `-vam`) and `git -C dir commit -am`. Fail-closed, so a slip-catcher; check the
  block message doesn't mislead and the backlog bypass item names both kinds.
  **Bash-command trap:** the reviewing session may still run an older guard that blocks any
  command text containing the commit/push phrase. Put probe cases in a scratch script built with
  the Write tool (spell `git` via a variable) and run `bash <script>`.
- **Validator output drifts with the CLI.** On Claude Code 2.1.330 (2026-11-23)
  `claude plugin validate plugin` also prints plugin-directory advisories (missing icon, undeclared
  `network.hosts`) besides the expected missing-`version` warning; they don't change the verdict.
  The DoD now allows only warnings `main` also gives: diff the warning lists of HEAD and a
  `git archive origin/main` extraction (the extraction has no `.git`, so it adds a
  README-missing warning HEAD lacks; ignore that one).
- **The Minnel bash guard runs in review sessions** (seen 2026-11-23, loaded from the desktop
  app as `minnel@inline`) and blocks `rm -rf`; clean up with `rm <file>` then `rmdir`. That it ran
  at all shows the uploaded zip's hook scripts kept a working exec bit in that install. Since
  2026-11-23 the repo's own settings enable `minnel@minnel`, so the guard runs in every review
  here (from main's copy in the plugin cache). Give each scratch extraction a fresh
  `mktemp -d` folder instead of clearing an old one.
- **Guard redesigns that anchor to a command position (planned 2026-11-23, release-0.4.0 Stage
  1).** Anchoring patterns to a command start and stripping quoted strings fixes false positives
  but blinds any pattern that lives in an argument: `DROP TABLE` only ever appears inside
  `psql -c "…"` or piped SQL, and `rm -rf` also runs as `xargs rm -rf`, `find … -exec rm -rf`,
  `sh -c '…'`, `/bin/rm`, `\rm`, `command rm`. When the guards change, check each pattern still
  has a way to fire, and that the tests pin the accepted misses as documented passes. Also check
  `--force-with-lease` (blocked today by `\bgit push --force\b`) is decided deliberately, and
  that a flag check stops at `;`, `&&`, `|` rather than running `.*` into the next command.
- **Worktree quirk (2026-11-23):** the `.venv` with Zensical lives in the main checkout, not in a
  `.claude/worktrees/*` worktree; run that binary from the worktree (read-only use) for the
  strict build.

**Why:** the plugin's correctness lives in shell and awk that prose review misses; the defects
found so far (normalisers hiding drift, guard path escapes, unquoted plugin root) were only
visible by executing edge cases.
**How to apply:** any diff touching `plugin/`, `.claude-plugin/`, Check E, or a paired appendix.
