---
name: project-session-concurrency-guidance
description: §9 shared-checkout and single-owner guidance and §11 other-sessions-as-input paragraph (review 2026-11-22); the git-worktree-list misreading and the desktop Worktree default to re-check
metadata:
  type: project
---

Checked 2026-11-22 in the PR #9 review; points 3 and 4 revised 2026-11-23. Re-verify before relying on it.

- The desktop-app worktree correction in §9 matches the Claude Code desktop docs as fetched on 2026-11-22: the **Worktree** option is off by default and is set per session or as a saved-environment default. A later edit may change this; re-fetch `code.claude.com/docs/en/desktop` before trusting it.
- `git worktree list` lists checkouts and their branches. It does not list sessions. Two sessions in one checkout show as one entry. Any doc wording that says it reveals "which branch each session holds" or "where a session is" is wrong.
- The approval rule is stated in three places: §9 "One owner for shared state", §11 "Other sessions as input", and its CHANGELOG line. They agreed as of 2026-11-23 ("the user who owns the work, in that user's own session"); when one changes, check the other two. Don't flag divergence from the user's personal global-rule phrasing ("the session that needs it"), which is not repo text.
- CHANGELOG categories: corrections to content already in a tagged release go under *Fixed* (e.g. the §9 desktop-worktree claim, shipped in 0.3.1, corrected under [Unreleased] Fixed). Corrections to content still in [Unreleased] fold into its *Added* entry, per the DoD's changelog item.

**Why:** these were the defects found on the first review of the shared-checkout guidance.
**How to apply:** when §9 or §11 are edited again, check the four points above first.
