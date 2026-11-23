---
name: accept
description: Run the Definition of Done against the current diff before calling a change complete.
disable-model-invocation: true
---

Check the current change against the Definition of Done. Do not declare it done until
every item is verified — you will not do this for me unless asked, so I am asking.

1. Run `git diff` (and `git status`) to see exactly what changed.
2. Walk the Definition of Done in `.claude/rules/definition-of-done.md` item by item.
   For each, state the command you ran or the evidence, and PASS / FAIL — not a vibe.
   An item due only before merge, such as the review, is *pending* until the branch
   is ready to merge, not FAIL.
3. Confirm the current stage's acceptance criteria in the active plan (docs/plans/) are met.
4. If anything FAILS or cannot be verified, stop and report it plainly. Do not work
   around it or soften the wording; list exactly what remains.
5. Only when every item passes, or is pending until merge, report the change ready —
   and remind me to advance the plan status (Appendix D) and draft any user-facing
   line into CHANGELOG Unreleased (Appendix H).
