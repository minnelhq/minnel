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
  per the plugin doc). Run real commit messages through the commit form: only `DROP TABLE`
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
  `./guards.sh`. Claude Code's `/doctor prompt-audit` overlaps it for instruction files; check the
  docs keep that positioning.
- **Shells and `echo` (2026-11-24, retro-findings branch).** `guards.sh` is bash-only and, from that
  branch, re-execs under bash when run by dash or a POSIX-mode bash. Probe it under `sh`, `dash`,
  `zsh`, `bash --posix`, and `POSIXLY_CORRECT=1` (bash re-enters POSIX mode from that variable). On
  macOS the POSIX-mode bash that is `/bin/sh` makes `echo` expand backslashes, so `echo "$payload"`
  turns JSON `\n` into raw newlines: that, not quoting, was the "8 false FAILs" under `sh`; dash
  instead aborts with a parse error after 35 cases. The guards used to read input with
  `echo "$INPUT" | jq`, so with `POSIXLY_CORRECT` set any JSON escape (`\n`, `\t`, `\\`) broke the
  parse and the guard allowed the call; for tests-dir-guard that meant nearly every test-writer
  Write, since content has newlines. Fixed in 32b0a0b (printf '%s\n'); flag any new `echo` of tool
  input. The root class remains: a jq parse failure still reads as empty and allows. `all-awks.sh` runs `guards.sh` per awk; probe it with a
  broken fake awk first on PATH (exit 1), a PATH holding only `/usr/bin:/bin` plus a jq link (skips,
  exit 0), `CDPATH` set, and `kill -TERM` under dash (EXIT trap doesn't run, temp dir leaks).

- **The Appendix Q `commit-msg` hook (`plugin/skills/scaffold/templates/commit-msg`; 2026-11-25
  shape).** Probe it with real `git commit` runs in throwaway repos via `core.hooksPath`, under
  `sh` and a `#!/bin/dash` copy, from a script written with the Write tool. Cases that showed
  defects or gaps: a *new* commit reusing HEAD's subject (`fix: lint` twice) passes with no
  changelog line, because the amend leg can't tell an amend from a new commit (git exports
  `GIT_AUTHOR_DATE`, which an amend keeps from HEAD: observed on 2.54, a possible signal);
  `git merge --squash`'s "Squashed commit of the following:" and a conflicted revert-of-revert's
  `Reapply "…"` are git-written yet refused; `core.commentChar`; `-v` with an empty message;
  `echo "$MSG"` under dash eats `\c`. `git revert`/`cherry-pick` don't run commit-msg at all, so
  "every commit in the clone" over-claims. For the scaffold's install step, Husky v9 sets
  `core.hooksPath` to the generated, gitignored `.husky/_` (read from husky 9.1.7's `index.js`),
  so "copy into the directory core.hooksPath names" overwrites its stub.
  Re-review of the fixes (2026-11-25): Husky 9's `_/h` runner calls `sh -e .husky/<hook> "$@"`
  (read from the registry tarball's `husky` file), so probe the hook under `sh -e` too: a bare
  `X=$(git config unset.key)` exits 1 there and refused every commit. Git's merge titles come in
  plurals (`Merge tags`, `Merge commits`, `Merge remote-tracking branches`) and `git pull <url>`
  of HEAD writes `Merge <url>`; an allow-list needs each, with a test per form. An
  "empty message, leave it to git" exit also passes `git commit -m '#42 x'` (no editor, so git
  keeps the line). `git check-ignore .husky/_` reports *not* ignored (its `*` is inside it); check
  a file path in it. `log.showSignature` only adds output for a signed HEAD (`gpg.format ssh` with
  `ssh-keygen` is enough to test it). A test whose setup commit can fail (signing) passes vacuously
  if the staged change still satisfies the hook: break the setup (`GIT_CONFIG_COUNT=1` with
  `gpg.ssh.program` pointing at a script that exits 1) and rerun the mutant. The suite's repos
  inherit global git config; this machine sets a global `core.hooksPath` (2026-11-25).

**Why:** the plugin's correctness lives in shell and awk that prose review misses; the defects
found so far (normalisers hiding drift, guard path escapes, unquoted plugin root) were only
visible by executing edge cases.
**How to apply:** any diff touching `plugin/`, `.claude-plugin/`, Check E, a paired appendix, or
`.github/workflows/guards.yml`.
