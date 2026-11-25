---
paths:
  - "plugin/scripts/*guard*.sh"
---

# Changing a guard

A change to what a guard blocks also changes the prose that describes it. Update every place
that does, in the same commit:

- the guard's copy and caption in Appendix C (`docs/appendices/hooks.md`; Check E compares the
  copy)
- §6 and §11 in `docs/methodology.md`, and Appendix O's "Guards wired" item
  (`docs/appendices/skeletons.md`)
- `docs/plugin.md`'s guards paragraph, `plugin/README.md` and the README's guards entry
- the scaffold's guard question (`plugin/skills/scaffold/SKILL.md`) and the description in
  `plugin/hooks/hooks.json`

Then grep for the guard's stance as well as its name, since the prose often paraphrases it
("destructive commands", "blanket staging").

Before widening a git match, try real git in a scratch repo:
`git <sub> <opt> --definitely-bogus` reports the bogus flag only when git accepted `<opt>`.
An abbreviation one subcommand takes for one option can mean another option elsewhere (the
`--no-v` forms read as `--no-verbose` on add, fetch and status). Pin each false positive you
reject with a pass case in `plugin/scripts/tests/guards.sh`.
