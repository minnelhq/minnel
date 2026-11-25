# Methodology appendices

Drop-in artefacts for [the methodology](../methodology.md), grouped by type and split out of the
main document so the narrative (§1–§11) stays readable. A letter is a stable identifier, not a
position — the security checklist is Appendix O (the next free letter when it was added) yet
lives in the skeletons file, with its kind.

- **[subagents.md](subagents.md)** — A code-reviewer, B test-writer
- **[hooks.md](hooks.md)** — C project hooks, Q git `commit-msg` hook
- **[skeletons.md](skeletons.md)** — D plan file, E Definition of Done, F backlog, G ADR,
  H changelog, O security checklist
- **[skills-and-commands.md](skills-and-commands.md)** — I example skill, J /plan, K /accept,
  L /retro, M /release, N /wrap, P /triage

The plugin in `plugin/` ships Appendices A and B, the Appendix C guards, J–N and P, and its
`/minnel:scaffold` skill writes D–H into a project (see
[Minnel as a plugin](../plugin.md)). It ships the Appendix Q hook beside the scaffold's
templates. I and O stay as documentation.
