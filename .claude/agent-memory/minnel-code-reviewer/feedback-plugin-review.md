---
name: feedback-plugin-review
description: How to review the Minnel plugin (plugin/, .claude-plugin/) and the consistency hook's Check E that pins it to the appendices — test by mutation, not by reading
metadata:
  type: feedback
---

The plugin's artefacts are pinned to the appendices by Check E in
`.claude/hooks/docs-consistency.sh` (see [[project-plugin-minnel]], [[feedback-hook-script-review]]).
The DoD's Plugin and hook-safety items list the commands to run and the quoting rule; this file
covers how to probe.

- **Mutation-test Check E in a scratch copy, never by reading the awk.** Extract the branch with
  `git archive` into a fresh `mktemp -d` folder, `git init` there so the check-ignore gate works,
  mutate one side, and pipe a synthetic payload into the hook under `dash` with
  `CLAUDE_PROJECT_DIR` set to the copy; expect exit 2. Cases: an extra frontmatter key on the
  plugin side, a body line on either side, a key added after B's `hooks:` block, a blank line
  inside that block (must stay 0), a skill losing `disable-model-invocation: true`.
- **Normalisers should be one-sided and deny-list shaped.** One that keeps only allow-listed
  fields, or runs on both sides, hides drift. Ask which side a new one runs on and what it would
  hide. The plugin-side settings normaliser is marker-bounded: code between the markers is
  invisible to Check E, so read that block by eye.
- **Hard-coded skill lists drift.** Prefer a glob over `plugin/skills/*/SKILL.md`, and check
  "every plugin skill" wording against what a loop covers.
- **`tests-dir-guard.sh` path escapes:** `..` mid-path, trailing `/..`, a path outside the project
  containing `tests/`, a sibling prefix (`/proj2/...` with project `/proj`). Pin them in
  `plugin/scripts/tests/guards.sh`.
- **Git guard decisions (allow/ask/block).** A test must tell exit 0 *with* "ask" JSON from a
  plain 0. Cases: `git commit -a`/`-am`/`--all` and clusters where `a` isn't first (`-qam`),
  global options before the subcommand (`git -C dir push`, `-c k=v`, `--no-pager`), mixed-case and
  empty settings, a commit-then-push chain under each setting. `guards.sh` inherits the caller's
  environment, so an exported `MINNEL_GIT_GUARD_*` skews its default cases unless it unsets them.
- **When the guards change**, check each pattern still has a way to fire (`DROP TABLE` lives in an
  argument; `rm -rf` also runs via `xargs`, `find -exec`, `/bin/rm`, `\rm`), that the tests pin the
  accepted misses as documented passes, and that a flag check stops at `;`, `&&`, `|`.
- **The segmenter (`plugin/scripts/command-segments.awk`).** Both guards match on its output, so a
  shape it mis-splits is a silent miss. Probe with `printf '%s\n' "$cmd" | awk -f …` from a scratch
  script built with the Write tool (spell `git` via a variable), and compare against `main`'s
  verdict. Shapes: keywords before a command (`do rm`, `! git push`); a `#` comment holding an
  apostrophe; `"$(git push)"` and backticks in double quotes; Claude's commit form
  `git commit -m "$(cat <<'EOF' … EOF )" && git push`; `$((1<<2))`, `$((1<<n))` and `(( x <<= n ))`;
  `case … in a) …` inside `"$(...)"`; `/usr/bin/sudo`; a missing awk file (the guard must block,
  per the packaging doc). Run real commit messages through the commit form: only `DROP TABLE`
  mentions should block. Quoted text accumulates char by char (quadratic on BSD awk).
- **Guards CI (`.github/workflows/guards.yml`).** Read the job logs (`gh run view --job <id> --log`),
  not the tick: the awk check step should print `mawk …` / `GNU Awk …` and the tests 0 `FAIL`.
  Older mawk (20200120) is untested, and lacks `{n,m}` and `[[:class:]]`; re-grep for them if the
  awk changes. Matrix values reach `run:` only through `env:`.
- **Packaging script (`scripts/package.sh`).** Test in a `git archive` copy: an ignored file in
  `plugin/` (`.env`) and an absolute symlink out of the repo (`cp -R` keeps it, `zip -r` follows
  it). Check `CDPATH= cd`, that a failed validate stops the build, that the version can't hold `/`,
  and that a `git archive | tar -x` pipeline isn't hiding a failure (no pipefail in POSIX sh; bsdtar
  exits 0 on empty input; prefer `git archive -o`). A `--dev` build from HEAD drops uncommitted
  edits; the script should say so at run time.
- **Validator warnings.** Since 0.4.0, `claude plugin validate` passes clean on `plugin` and `.`, so
  any warning on a branch is new; the DoD allows only warnings `main` also gives (diff against a
  `git archive origin/main` extraction, ignoring its README-missing warning).
- **Version-gated claims:** check Claude Code's own CHANGELOG (see [[reference-docs-fetch]]), not
  the validator's hint; slash-command and CLI forms land in different versions.
- **`config-audit.sh`, the retro's read-only audit (first reviewed 2026-11-24).** Mutate it in a
  `git archive` copy: each `list_files` location, `find -L` (symlinked rules), the anchored tail
  match (`docs/c.js` beside `docs/c.json`), the `./` strip, the git-remote skip (a blanket `@` skip
  hid `node_modules/@types/...`) and a line-start `@import` must each fail a guards.sh case. A new
  file location needs its own case. `${CLAUDE_PLUGIN_ROOT}` (and `${CLAUDE_PROJECT_DIR}`) are
  substituted in a plugin skill's body and `allowed-tools` Bash rules, not in the Bash tool's
  environment. To run it under dash, put an `sh -> /bin/dash` link first on PATH and run
  `./guards.sh` (bash-only; `sh ./guards.sh` gives 8 false segmenter FAILs on macOS). Claude Code's
  `/doctor prompt-audit` overlaps it for instruction files; check the docs keep that positioning.

**Why:** the plugin's correctness lives in shell and awk that prose review misses; the defects
found so far (normalisers hiding drift, guard path escapes, unquoted plugin root) were only
visible by executing edge cases.
**How to apply:** any diff touching `plugin/`, `.claude-plugin/`, Check E, a paired appendix, or
`.github/workflows/guards.yml`.
