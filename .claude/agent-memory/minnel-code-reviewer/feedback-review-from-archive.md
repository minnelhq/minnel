---
name: feedback-review-from-archive
description: Review a branch from git objects, not the working tree — other sessions switch the shared checkout mid-review
metadata:
  type: feedback
---

Read and test the branch under review from git objects (`git show <branch>:<path>`, or
`git archive <branch> | tar -x -C <scratchpad>/x`), not from the working tree. Before merge, also
`git fetch` and run `git merge-tree --write-tree --name-only origin/main <branch>` to catch
conflicts with work merged since the branch point.

**Why:** in the 2026-11-23 `feat/plugin` review, another session switched the shared checkout to a
different branch partway through, so later reads of `plugin/` failed and a doc "changed on disk".
The same review found `origin/main` had moved (backlog and CHANGELOG), so the branch no longer
merged cleanly and some new backlog items contradicted the branch's design.

**Stale local `main`.** The reviewer's step 1 says `git diff main...HEAD`, but a worktree's local
`main` is often behind `origin/main`: on 2026-11-23 (backlog-triage-8e25d5) local `main` sat one
merge behind, so `main...HEAD` showed 33 files, most of them PR #23's, against a 2-file branch.
Always `git fetch`, compare `git rev-parse main origin/main`, and diff `origin/main...HEAD`.

**Greps against a commit.** Run `git grep -nE '<pattern>' <sha> -- <pathspecs>` in the real worktree rather than committing the extraction: the Minnel git guard blocks `git add -A` even in a scratch repo, and a blocked command runs none of its parts, so a `mktemp -d` in the same command never happens (seen 2026-11-24).

**Scratch extraction.** The bash-guard blocks `rm -rf`, so don't clear a scratch dir; extract
into a fresh `mktemp -d "$SCRATCH/x.XXXX"` each time. The site build needs the main checkout's
`.venv` (worktrees have none): `<main>/.venv/bin/zensical build --strict --clean` run from the
extracted copy (seen 2026-11-24).

**How to apply:** never switch the checkout back yourself (it belongs to the other session); say
in the report that it moved. Run the site build and hook tests against the extracted copy.
