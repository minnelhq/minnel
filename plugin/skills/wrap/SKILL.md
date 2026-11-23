---
name: wrap
description: Close out the session — confirm durable records are current, then summarise and name it.
disable-model-invocation: true
---

End-of-session wrap. Work in order; do not edit files until I confirm each write.

1. Durable records — check and update:
   - Active plan: advance the current stage, tick completed steps, note deviations.
   - Changelog: draft any user-facing changes in the format the project's `CLAUDE.md`
     Conventions name (Keep a Changelog under [Unreleased] by default).
   - Decisions: log any made this session in the plan, or propose an ADR if significant.
2. Retro signal: list anything I had to correct more than once, and propose the single
   durable fix for each (a CLAUDE.md/rules entry, a hook, a subagent, a skill).
3. Pointer summary: one line naming which artefacts this session touched and where
   things landed — not a re-narration of the work.
4. Suggest a session name mirroring the active plan (e.g. add-importer), so the session
   and plan cross-reference.

Produce all of the above yourself from the session and git history. Do not rely on the
native /recap — it may be unavailable in this environment.
