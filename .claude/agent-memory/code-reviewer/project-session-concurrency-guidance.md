---
name: session-concurrency-guidance
description: §9 shared-checkout and single-owner guidance and §11 other-sessions-as-input paragraph (review 2026-11-22); the git-worktree-list misreading and the desktop Worktree default to re-check
metadata:
  type: project
---

Checked 2026-11-22 on branch docs/cross-session-concurrency, before merge. Re-verify before relying on it.

- The desktop-app worktree correction in §9 matches the Claude Code desktop docs as fetched on 2026-11-22: the **Worktree** option is off by default and is set per session or as a saved-environment default. A later edit may change this; re-fetch `code.claude.com/docs/en/desktop` before trusting it.
- `git worktree list` lists checkouts and their branches. It does not list sessions. Two sessions in one checkout show as one entry. Any doc wording that says it reveals "which branch each session holds" or "where a session is" is wrong.
- Approval authority is worded two ways (§9 "the user who owns the work", §11 and CHANGELOG "the user in the session that needs it"). Check that they name one rule.
- CHANGELOG categories: 0.3.1 used *Fixed* for a correction to released guidance. Corrections to released content go under *Fixed*; new guidance goes under *Added*. The DoD's "corrections stay under Added" rule only applies before a released baseline exists.

**Why:** these were the defects found on the first review of the shared-checkout guidance.
**How to apply:** when §9 or §11 are edited again, check the four points above first.
