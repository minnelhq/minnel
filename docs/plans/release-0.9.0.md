# Plan: Release 0.9.0, the --no-verify guard and a line-length check   (approved 2026-11-25)

**Status:** Stage 1 in progress.

## Goal
The bash guard blocks Claude from skipping git hooks with `--no-verify`, and the repository's
consistency hook flags over-long lines in the hard-wrapped files.

Why: Appendix Q's `commit-msg` hook shipped in 0.8.0, and Claude can step over it with
`git commit --no-verify`. The 0.8.0 review twice caught over-long lines left in hard-wrapped
files after a sentence was swapped in without reflowing. The house-voice self-test names that
defect, but nothing checks it. Both are `feat`, so this is a minor release.

Decisions:
- The rule lives in the bash guard, under `MINNEL_BASH_GUARD`. No new setting.
- It catches any git command with `--no-verify` (in git the flag always means "skip hooks"),
  plus `git commit -n`.
- Check G covers the hard-wrapped files: `CHANGELOG.md`, `CONTRIBUTING.md`, `README.md`,
  `plugin/README.md`, `docs/index.md`, `docs/backlog.md` and live plans in `docs/plans/`.

## Out of scope
- Bypasses the segment parser doesn't see: `git -c core.hooksPath=…`, aliases, `sh -c`. The guard
  stays a tripwire.
- Check G for the docs that keep one paragraph per line (`methodology.md`, `plugin.md`,
  `worked-example.md`, the appendices), ADRs, archived plans and `.claude/`.
- Cutting 0.9.0 before the maintainer says so (Stage 4).

---

## Stage 1 — Block `--no-verify` in the bash guard   [in progress]
- [ ] `plugin/scripts/bash-guard.sh`: after the force-push rule, block any `git` command with
      `--no-verify` (or the shortest unambiguous abbreviation, `--no-veri`), and `git commit`
      with `-n` in a short-option cluster, using the git guard's value-letter exclusion so `-mn`
      and `-uno` pass. `git push -n` (a dry run) passes.
- [ ] `docs/appendices/hooks.md`: the Appendix C copy gets the same lines; update its caption
      and the Appendix Q paragraph on `--no-verify`.
- [ ] `plugin/scripts/tests/guards.sh`: block, ask and pass cases.
- [ ] Docs that list what the bash guard catches: `docs/plugin.md`, `plugin/README.md`,
      `README.md`, `plugin/skills/scaffold/SKILL.md` and the `plugin/hooks/hooks.json`
      description.
- [ ] `CHANGELOG.md` Added line; delete the backlog item.
- Acceptance: `plugin/scripts/tests/all-awks.sh` passes under each installed awk (a `skip` is
  reported as unchecked); Check E passes for Appendix C; `claude plugin validate plugin` and
  `claude plugin validate .` give no warnings beyond `main`'s.

## Stage 2 — Check G, lines over 100 columns   [pending]
- [ ] `.claude/hooks/docs-consistency.sh`: a `check_g` that counts characters, not bytes (awk
      under `LC_ALL=C`, UTF-8 continuation bytes removed before `length()`), skipping fenced
      blocks and table rows. Run it on the files under Decisions, including `plugin/README.md`
      and live plans, which the hook otherwise leaves early. Update the header comment.
- [ ] Reflow `CHANGELOG.md` line 116, the one line in scope over 100 today.
- [ ] Name Check G wherever `CONTRIBUTING.md` or the house-voice rule lists the hook's checks.
- [ ] `CHANGELOG.md` Added line; delete the backlog item.
- Acceptance: under each installed awk, the hook flags a 101-column line in `CHANGELOG.md` and
  in a live plan, and passes a 100-column line with em-dashes, a long line in a fence, and long
  lines in `docs/methodology.md` and in an archived plan.

## Stage 3 — Review   [pending]
- [ ] `minnel:code-reviewer` on the branch diff; fix its findings and re-run per the working
      agreement.
- [ ] `zensical build --strict`, since published docs changed.

## Stage 4 — Release 0.9.0   [pending]
- [ ] On the maintainer's word, `/minnel:release`: the 0.9.0 changelog section, `plugin.json`'s
      `version`, this plan closed and archived, and Now reset. The tag and GitHub release follow
      the merge.
