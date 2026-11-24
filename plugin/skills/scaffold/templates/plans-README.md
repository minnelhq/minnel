# Plans

One file per multi-stage task, `docs/plans/<task-name>.md`, with its status folded in. The
backlog's "Now (this plan)" line or the `CLAUDE.md` "Active plan" line names the live one.
When a plan is done, set `**Status:** done (YYYY-MM-DD)`, clear the pointer, and move the file
to `docs/plans/archive/`. `/minnel:wrap` does this once the last stage has passed the Definition
of Done.

When each stage merges on its own branch, the stage's last commit names the next stage, in the
status line, the stage markers and the pointer, so the plan on the main branch stays true after
the merge. Record "awaiting review" in the pull request, not the plan.

Skeleton:

```markdown
# Plan: <task name>   (approved YYYY-MM-DD)

**Status:** in progress — Stage 2 of 3
<!-- The active-plan pointer (e.g. in CLAUDE.md, docs/plans/README.md, or your backlog) names this file. -->

## Goal
<one or two sentences>

## Out of scope
- <thing we are deliberately not doing>

---

## Stage 1 — <name>   [done]
- [x] <step> — files: <paths>
- [x] <step>
- Acceptance: <how we knew the stage was done>

## Stage 2 — <name>   [current]
- [x] <step>
- [ ] <step> — files: <paths>
- Acceptance: <criteria for this stage>

## Stage 3 — <name>   [not started]
- [ ] <step>
- Acceptance: <criteria>

---

## Deviations
- YYYY-MM-DD, Stage 2 — changed X because Y.

## Decisions
- YYYY-MM-DD — <decision> — because <reason>.
  <!-- If architecturally significant and costly to reverse, promote to docs/design/ as an ADR. -->
```
