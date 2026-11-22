# Definition of Done

A change is not done until ALL of these hold. Do not report a task complete
until you have checked each one and can say which command or evidence confirms it.

- [ ] Builds cleanly (`<build command>`).
- [ ] Tests pass, including new tests for the changed behaviour (`<test command>`).
- [ ] `code-reviewer` subagent run on the diff, with no Critical findings outstanding.
- [ ] No new lint/format violations (`<lint command>`).
- [ ] Project invariants in CLAUDE.md still hold.
- [ ] Active plan in `docs/plans/` updated: current stage advanced, items ticked or deviations recorded.
- [ ] Docs/comments updated if the public surface changed.

If any item cannot be met, stop and say so rather than working around it.
