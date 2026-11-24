---
name: project-plan-archiving
description: The plan-archiving convention (completed plans move to docs/plans/archive/) and the doc spots that describe it
metadata:
  type: project
---

Completed plans move from `docs/plans/` to `docs/plans/archive/`, staying versioned as history so only live work shows in `docs/plans/`. Convention added 2026-06.

Where it is described (keep these consistent on any future edit):
- `docs/methodology.md` §3, its closing paragraph — "when a plan is done, move it to `docs/plans/archive/` and clear the active-plan pointer".
- Appendix D in `docs/appendices/skeletons.md`, the skeleton's completion note — set `**Status:** done (YYYY-MM-DD)`, clear the pointer, move to archive.
- Appendix N (`docs/appendices/skills-and-commands.md`) and its plugin copy `plugin/skills/wrap/SKILL.md` — step 2, plan close-out (added 2026-11-24; replaced this repo's `close-plan` skill). Also pointed at from §3, §9 "Session close-out", §10's ritual table, Appendix D and the scaffold's `plans-README.md`.

**Why:** keeps the active plan set scannable for a cold-start session.

**Pointer location:** the live active-plan pointer is `## Now (this plan)` in `docs/backlog.md` (`- (none — no active plan)` when idle) — *not* `CLAUDE.md` or `docs/plans/README.md` (the latter does not exist). §3 point 3 and Appendix D give a non-exhaustive "e.g." list that names `docs/backlog.md` as this repo's instance. A doc naming this repo's concrete pointer should say `docs/backlog.md`; adopter-facing artefacts (Appendix N's close-out step, the plugin's wrap skill) deliberately name no single location and must not hard-code it.

**Stage markers:** skeleton (Appendix D, `docs/appendices/skeletons.md`) uses three states — `[done]`, `[current]`, `[not started]`. A close-out grep that only looks for `[current]` and `[ ]` misses a leftover `[not started]` stage.

**How to apply:** "clear the pointer" maps to resetting `docs/backlog.md` `## Now (this plan)`. Appendix J and its plugin skill, `templates/CLAUDE.template.md`, README "file layout" and the DoD all still say plans live in `docs/plans/` generically; that stays *true* (archive is a subdir), so they are NOT made wrong by the convention and need not be touched. Only flag them if a future edit asserts completed plans stay in `docs/plans/` directly. See [[project-repo-shape]].
