---
name: project-session-concurrency-guidance
description: §9 shared-checkout, single-owner and .worktreeinclude guidance, §11 other-sessions-as-input; worktree-list misreading, desktop default, what .worktreeinclude copies
metadata:
  type: project
---

First checked 2026-11-22 (PR #9); re-verify before relying on it.

- **Desktop worktrees.** §9 says the desktop app's Worktree option is off by default. That matched
  `code.claude.com/docs/en/desktop` on 2026-11-22; re-fetch before trusting it.
- **`git worktree list`** lists checkouts and their branches, not sessions; two sessions in one
  checkout show as one entry. Wording saying it reveals "which branch each session holds" is wrong.
- **The approval rule** is stated in §9 "One owner for shared state" and §11 "Other sessions as
  input" ("the user who owns the work, in that user's own session"). When one changes, check the
  other. Don't flag divergence from the user's personal global rule, which isn't repo text.
- **`.worktreeinclude` (§9).** Docs (`worktrees.md`, "Copy gitignored files into worktrees"): it
  applies to every worktree Claude Code creates with git (`--worktree`, subagent worktrees,
  desktop), and a `WorktreeCreate` hook replaces it. Read from the 2.1.330 binary (inferred, not
  observed): the copy runs only at creation, never on reuse; candidates come from
  `git ls-files --others --ignored --exclude-standard`, so `.git/info/exclude` counts; the file is
  read from the main checkout's root, tracked or not; symlinked entries are skipped with a warning.
  Deliberately unsaid in §9: the `WorktreeCreate` bypass and no-copy-on-reuse; don't re-raise
  unless the text starts claiming otherwise. Technique: `strings -n 8 <binary> | grep -n
  worktreeinclude`, then print context with Python (BSD grep caps `{0,N}` at 255).
- **Nested repos (2026-11-24).** §9 says a listed folder that is its own git repository isn't
  copied (observed on 2.1.330) and suggests symlinking it from a `SessionStart` hook. Whenever §9
  recommends a symlink, check the ignore rule: a pattern with a trailing slash (`notes/`) matches
  directories only, so the link shows as untracked and can be committed; `notes` ignores it
  (verified in a scratch repo).

**Why:** these were the defects found on the first reviews of the shared-checkout guidance.
**How to apply:** when §9 or §11 are edited again, check these points first.
