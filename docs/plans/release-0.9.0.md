# Plan: Release 0.9.0, the --no-verify guard and a line-length check   (approved 2026-11-25)

**Status:** Stages 1–3 done; Stage 4 (the release) waits on the maintainer.

## Goal
The bash guard blocks Claude from skipping git hooks with `--no-verify`, and the repository's
consistency hook flags over-long lines in the hard-wrapped files.

Why: Appendix Q's `commit-msg` hook shipped in 0.8.0, and Claude can step over it with
`git commit --no-verify`. The 0.8.0 review twice caught over-long lines left in hard-wrapped
files after a sentence was swapped in without reflowing. The house-voice self-test names that
defect, but nothing checks it. Both are `feat`, so this is a minor release.

Decisions:
- The rule lives in the bash guard, under `MINNEL_BASH_GUARD`. No new setting.
- It catches any git command with `--no-verify` (in git the flag means "skip hooks" everywhere
  but `git show-ref`, where blocking it costs nothing), plus `git commit -n`.
- Check G covers the hard-wrapped files: `CHANGELOG.md`, `CONTRIBUTING.md`, `README.md`,
  `plugin/README.md`, `docs/index.md`, `docs/backlog.md` and live plans in `docs/plans/`.

## Out of scope
- Bypasses the segment parser doesn't see: `git -c core.hooksPath=…`, aliases, `sh -c`, a quoted
  `'--no-verify'` (quoted text reads as Q, as a quoted `'--force'` does) and `HUSKY=0` (a
  `VAR=value` word is dropped). The guard stays a tripwire.
- `git am -n` and `git am --no-v` to `--no-ver`, which skip the applypatch hooks but not
  `commit-msg`. Matching those short forms on every git command would catch `--no-verbose`.
- Check G for the docs that keep one paragraph per line (`methodology.md`, `plugin.md`,
  `worked-example.md`, the appendices), ADRs, archived plans and `.claude/`; and for the
  hard-wrapped plugin skills and agents and `templates/`, whose frontmatter holds long lines.
- Cutting 0.9.0 before the maintainer says so (Stage 4).

---

## Stage 1 — Block `--no-verify` in the bash guard   [done]
- [x] `plugin/scripts/bash-guard.sh`: after the force-push rule, block any `git` command with
      `--no-verify` (or `--no-veri`, the shortest form commit takes), and `git commit`
      with `-n` in a short-option cluster, using the git guard's value-letter exclusion so `-mn`
      and `-uno` pass. `git push -n` (a dry run) passes.
- [x] `docs/appendices/hooks.md`: the Appendix C copy gets the same lines; update its caption
      and the Appendix Q paragraph on `--no-verify`.
- [x] `plugin/scripts/tests/guards.sh`: block, ask and pass cases.
- [x] Docs that list what the bash guard catches: `docs/plugin.md`, `plugin/README.md`,
      `README.md`, `plugin/skills/scaffold/SKILL.md` and the `plugin/hooks/hooks.json`
      description. `README.md` lists the guards only as examples ("such as"), so it stays as
      it is; §6's sentence on `--no-verify` names the guard instead.
- [x] `CHANGELOG.md` Added line; delete the backlog item.
- Acceptance: `plugin/scripts/tests/all-awks.sh` passes under each installed awk (a `skip` is
  reported as unchecked); Check E passes for Appendix C; `claude plugin validate plugin` and
  `claude plugin validate .` give no warnings beyond `main`'s.
  Result: 214 cases pass under awk 20200816, mawk 1.3.4 and gawk 5.4.2; both validations pass
  with nothing to report.

## Stage 2 — Check G, lines over 100 columns   [done]
- [x] `.claude/hooks/docs-consistency.sh`: a `check_g` that counts characters, not bytes (awk
      under `LC_ALL=C`, UTF-8 continuation bytes removed before `length()`), skipping fenced
      blocks and table rows. Run it on the files under Decisions, including `plugin/README.md`
      and live plans, which the hook otherwise leaves early. Update the header comment.
- [x] Reflow `CHANGELOG.md` line 116, the one line in scope over 100 today.
- [x] Name Check G wherever `CONTRIBUTING.md` or the house-voice rule lists the hook's checks.
      `CONTRIBUTING.md` lists them; the house-voice self-test names the spliced-line defect, so
      it gains a sentence pointing to Check G.
- [x] `CHANGELOG.md` Added line; delete the backlog item.
- Acceptance: under each installed awk, the hook flags a 101-column line in `CHANGELOG.md` and
  in a live plan, and passes a 100-column line with em-dashes, a long line in a fence, and long
  lines in `docs/methodology.md` and in an archived plan.
  Result: all eight cases pass under awk 20200816, mawk 1.3.4 and gawk 5.4.2, with a
  `plugin/README.md` case and a table-row case added. The hook is clean on every in-scope file.

## Stage 3 — Review   [done]
- [x] `minnel:code-reviewer` on the branch diff; fix its findings and re-run per the working
      agreement.
  - Round 1: no Critical. Two Warnings, fixed: pass cases for each value letter in the `-n`
    cluster (cutting the class now fails five), and the bash guard's stance in §11 and
    Appendix O. Suggestions taken: match abbreviations down to `--no-v` (`git am` takes it),
    pass cases for `--no-verify-signatures` and `--no-verbose`, "backtick-fenced" in Check G's
    wording, a reflowed scaffold question, §6's sentence split, and the accepted misses named
    under Out of scope. Not taken: dropping "twice" from the Goal; the two cases were
    `plugin/README.md` and then `CHANGELOG.md`.
  - [x] Round 2 on the fix commit: no Critical. One Warning, fixed: a plan line cited private
    notes. Suggestion taken: `--no-v` to `--no-ver` also parse as `--no-verbose` on add, fetch,
    status and others, so the rule is back to `--no-veri` and longer, with `git am`'s short
    forms under Out of scope and a `git fetch --no-v` pass case. No third round: the Warning fix
    touches only this plan.
- [x] `zensical build --strict`, since published docs changed: no issues.

## Stage 4 — Release 0.9.0   [pending]
- [ ] On the maintainer's word, `/minnel:release`: the 0.9.0 changelog section, `plugin.json`'s
      `version`, this plan closed and archived, and Now reset. The tag and GitHub release follow
      the merge.
