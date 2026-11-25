---
paths:
  - "plugin/scripts/*guard*.sh"
  - "plugin/scripts/command-segments.awk"
---

# Changing a guard

A change to what a guard blocks also changes the prose that describes it. Update every place
that does, in the same commit.

For the bash and git guards, and `command-segments.awk`, which both read commands through:

- in `docs/appendices/hooks.md`: Appendix C's intro, the guard's copy and caption (Check E
  compares the copy), and the Appendix Q paragraph on `--no-verify`
- §6, §9 and §11 in `docs/methodology.md`, and Appendix O's "Guards wired" item
  (`docs/appendices/skeletons.md`)
- `docs/plugin.md`'s guard items under "Install this plugin", `plugin/README.md` and the
  README's guards entry
- the scaffold's guard question (`plugin/skills/scaffold/SKILL.md`), and the descriptions in
  `plugin/hooks/hooks.json`, `plugin/.claude-plugin/plugin.json` and
  `.claude-plugin/marketplace.json`

For the test-directory guard: its copy in Appendix B (`docs/appendices/subagents.md`), the
`test-writer` row in §4's roster and §6's subagent-hook paragraph.

Then grep for the guard's stance as well as its name, since the prose often paraphrases it
("destructive commands", "blanket staging", "test directories").

Before widening a git match, try real git in a scratch repo:
`git <sub> <opt> --definitely-bogus` reports the bogus flag only when git accepted `<opt>`.
An abbreviation one subcommand takes for one option can mean another option elsewhere (the
`--no-v` forms read as `--no-verbose` on add, fetch and status). Pin each false positive you
reject with a pass case in `plugin/scripts/tests/guards.sh`.
