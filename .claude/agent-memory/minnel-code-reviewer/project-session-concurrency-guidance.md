---
name: project-session-concurrency-guidance
description: §9 shared-checkout, single-owner and .worktreeinclude guidance, §11 other-sessions-as-input (reviews 2026-11-22/23); worktree-list misreading, desktop default, what .worktreeinclude copies
metadata:
  type: project
---

Checked 2026-11-22 in the PR #9 review; points 3 and 4 revised 2026-11-23. Re-verify before relying on it.

- The desktop-app worktree correction in §9 matches the Claude Code desktop docs as fetched on 2026-11-22: the **Worktree** option is off by default and is set per session or as a saved-environment default. A later edit may change this; re-fetch `code.claude.com/docs/en/desktop` before trusting it.
- `git worktree list` lists checkouts and their branches. It does not list sessions. Two sessions in one checkout show as one entry. Any doc wording that says it reveals "which branch each session holds" or "where a session is" is wrong.
- The approval rule is stated in three places: §9 "One owner for shared state", §11 "Other sessions as input", and its CHANGELOG line. They agreed as of 2026-11-23 ("the user who owns the work, in that user's own session"); when one changes, check the other two. Don't flag divergence from the user's personal global-rule phrasing ("the session that needs it"), which is not repo text.
- CHANGELOG categories: corrections to content already in a tagged release go under *Fixed* (e.g. the §9 desktop-worktree claim, shipped in 0.3.1, corrected under [Unreleased] Fixed). Corrections to content still in [Unreleased] fold into its *Added* entry, per the DoD's changelog item.

- `.worktreeinclude` in §9's "Isolate with git worktrees" paragraph (review 2026-11-23, claude/worktreeinclude-guidance). Docs (`code.claude.com/docs/en/worktrees.md`, "Copy gitignored files into worktrees"): applies to every worktree Claude Code creates *with git* (`--worktree`, subagent worktrees, desktop); a `WorktreeCreate` hook replaces it. Read from the 2.1.330 binary (inferred, not observed): the copy runs only when the worktree is newly created, never on reuse; the candidate list is `git ls-files --others --ignored --exclude-standard`, so `.git/info/exclude` and a global excludes file count as "gitignored"; the `.worktreeinclude` is read from the canonical main-checkout root by a plain file read, so tracked or not doesn't matter; symlinked entries are skipped with a warning. The exit cleanup check talks of "changed or untracked files", so edits to copied ignored files probably don't stop auto-removal (inferred). Technique: `strings -n 8 <binary> | grep -n worktreeinclude`, then print context with Python (BSD grep caps `{0,N}` at 255).

**Why:** these were the defects found on the first review of the shared-checkout guidance.
**How to apply:** when §9 or §11 are edited again, check the five points above first.
