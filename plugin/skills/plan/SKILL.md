---
name: plan
description: Enter plan mode with the house rules — explore read-only, challenge the approach, then present a plan for approval.
argument-hint: "<task>"
disable-model-invocation: true
---

Enter plan mode for: $ARGUMENTS

Work read-only until I approve a plan. Do not edit files.

1. Explore, read-only. Read the active plan in docs/plans/ and the invariants in CLAUDE.md
   yourself; delegate wider search to the Explore agent, restating any invariant it must respect
   (it skips CLAUDE.md, §1).
2. Decide whether to plan. Skip the ceremony for trivial work: a one-line or single-file change
   with no invariant in play. Say so and stop. Otherwise (a refactor, an architectural choice,
   or anything touching an invariant) continue.
3. Draft the plan: goal, ordered stages, per-stage steps with acceptance criteria, and an
   explicit out-of-scope list.
4. Challenge it before presenting (§2): argue why it might not be worth doing, and find the holes
   in the acceptance criteria. Fold what survives back in.
5. Present through the exit-plan tool. On approval, if the work is multi-stage or won't finish
   this session, write it to docs/plans/<name>.md (Appendix D) and update the active-plan
   pointer (§3) to name it.
