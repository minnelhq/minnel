---
name: wrap
description: Close out the session — confirm durable records are current, close a finished plan, then summarise and name it.
disable-model-invocation: true
---

End-of-session wrap. Work in order; do not edit files until I confirm each write.

1. Durable records — check and update:
   - Active plan: advance the current stage, tick completed steps, note deviations.
   - Changelog: draft any user-facing changes in the format the conventions in context
     name (Keep a Changelog under [Unreleased] by default).
   - Decisions: log any made this session in the plan, or propose an ADR if significant.
2. Plan close-out: if the active plan's last stage is finished and every Definition of
   Done item passes, or is pending until merge (such as the review), close the plan.
   - Set its Status line to `**Status:** done (YYYY-MM-DD) — <outcome>`: today's date and
     a one-line outcome, naming any stage that was cut or deviated.
   - Mark every stage `[done]`, giving a cut stage a deviation note that says so, and
     tick each completed step. Then confirm with
     `grep -nE '\[current\]|\[not started\]|^[[:space:]]*[-*] \[ \]' <plan>` that nothing
     is left but skipped steps. A skipped step stays unticked, with a deviation note.
   - Clear the active-plan pointer where CLAUDE.md says it lives (by default the
     backlog's Now section), so it names no plan.
   - Create docs/plans/archive/ if it is missing, then move the file there with `git mv`.
     If the plan was never committed, use `mv` and then `git add` the new path.
3. Retro signal: list anything I had to correct more than once, and propose the single
   durable fix for each (a CLAUDE.md/rules entry, a hook, a subagent, a skill).
4. Pointer summary: one line naming which artefacts this session touched and where
   things landed — not a re-narration of the work.
5. Suggest a session name mirroring the active plan, or the one just closed (e.g.
   add-importer), so the session and plan cross-reference.

Produce all of the above yourself from the session and git history. Do not rely on the
native /recap — it may be unavailable in this environment.
