# Plan: Prepare release 0.5.0   (approved 2026-11-24)

**Status:** in progress — Stage 3 of 4

## Context
`[Unreleased]` already holds a `feat` (§9 on `.worktreeinclude`), so the next release is a minor:
0.5.0, not 0.4.1. Three Next items fold into it: release targets in the backlog format, a
backlog-triage ritual, and Mermaid diagrams. Each builds on the last: triage proposes release
targets, and the §8 diagram shows targets and triage without a redraw. Decided at approval
(2026-11-24): targets are an inline `target: X.Y.Z` tag, and the site self-hosts a pinned mermaid.js
rather than load it from a CDN.

## Goal
Ship 0.5.0 with: optional release targets on backlog Next items, checked by `/minnel:release`; a `/minnel:triage`
ritual as Appendix P with its plugin skill; Mermaid diagrams for the §2 loop, the §8 lifecycle and
the §6 hook path, rendered on the site and on GitHub.

## Out of scope
The other backlog items (the `commit-msg` hook, the scaffold bootstrap, the guards' default);
re-lettering any appendix; the packaging doc's Check E diagram.

## How the stages run
One branch and one PR for the whole release, with the stages as commits in order. Each stage gets
a `minnel:code-reviewer` run on its own commits, with re-runs per the working agreement, and the
branch gets one more on its full diff before merge. The release commit (Stage 4) joins the branch
only on the maintainer's go, so the PR can wait ready without releasing anything. The stage that
ships a backlog item deletes its line and adds the `[Unreleased]` entry in the same commit. A
stage's last commit names the next stage in the status line, stage markers and pointer (Appendix D).
Check E pairs change together: Appendix F with the scaffold's `backlog.md`, Appendix M with
`plugin/skills/release/SKILL.md`, Appendix P with `plugin/skills/triage/SKILL.md`.

---

## Stage 0 — Record the plan   [done]
- [x] Copy this plan to `docs/plans/release-0.5.0.md` with the approval date — files:
  `docs/plans/release-0.5.0.md`
- [x] Set the backlog's Now to it, Stage 1 of 4; give the three items it ships a 0.5.0 target —
  files: `docs/backlog.md`
- Acceptance: the plan and pointer are on `main`; trivial branch, no review needed.

## Stage 1 — Release targets in the backlog format   [done]
- [x] Appendix F and the scaffold copy: an optional `target: X.Y.Z` on Next items, one header
  sentence on what it means; Later stays untargeted — files: `docs/appendices/skeletons.md`,
  `plugin/skills/scaffold/templates/backlog.md`
- [x] Appendix M and the plugin skill: a step that reads the backlog and lists any Next item still
  targeting the version being cut, as a warning in the draft; and the type's suggested bump (`feat`
  minor, `fix` patch, per Conventional Commits; `debt`/`chore` none unless an adopter would notice)
  — files: `docs/appendices/skills-and-commands.md`, `plugin/skills/release/SKILL.md`
- [x] §8: name the Now–Next–Later shape (credit Janna Bastow at ProdPad, checked against ProdPad's
  own page first), say targets are optional and Next-only, and that `/minnel:release` checks them — files:
  `docs/methodology.md`
- [x] This repo's own backlog header and items follow the format — files: `docs/backlog.md`
- [x] Delete the backlog item; `[Unreleased]` Added line — files: `docs/backlog.md`, `CHANGELOG.md`
- Acceptance: Check E clean on F and M; `zensical build --strict` clean; reviewer run with no
  Critical outstanding.

## Stage 2 — The backlog-triage ritual (Appendix P)   [done]
- [x] Run `add-section` for a new Appendix P (next free letter, append-only) in
  `skills-and-commands.md`, laid out like J–N: heading, "The plugin ships this as the `triage`
  skill" line, `` `.claude/commands/triage.md` `` marker, fenced command with
  `disable-model-invocation: true` — files: `docs/appendices/skills-and-commands.md`,
  `docs/appendices/README.md`
- [x] The skill's procedure, as a draft for approval: check each item still applies (shipped, stale,
  duplicated); re-tag and reorder Next; propose release targets (Stage 1's format) and groups. When
  `git check-ignore` confirms a gitignored notes backlog, read it too but show the combined grouping
  only in chat or write it to those notes; the tracked backlog groups tracked items only and names a
  private blocker in general terms — files: as above, `plugin/skills/triage/SKILL.md`
- [x] Check E row for P (`drop_skill_keys`, like J–N) — files: `.claude/hooks/docs-consistency.sh`
- [x] §10: table row and the rhythm sentence; every count and range: "five rituals" → six, "Six
  skills" → seven, A–O → A–P, J–N → J–N and P, using `add-section`'s grep plus a grep for ritual
  counts and the JSON manifests — files: `docs/methodology.md`, `README.md`, `CLAUDE.md`,
  `plugin/README.md`, `plugin/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
  `docs/packaging-as-a-plugin.md` (tree and table), `.claude/rules/definition-of-done.md`,
  `.claude/skills/add-section/SKILL.md`, reviewer memory `project-repo-shape.md`
- [x] Delete the backlog item; `[Unreleased]` Added line — files: `docs/backlog.md`, `CHANGELOG.md`
- Acceptance: Check A resolves Appendix P; Check E clean; `guards.sh`, both `claude plugin validate`
  runs and the strict build pass; a grep finds no stale "five rituals" or "A–O" outside history;
  reviewer run.

## Stage 3 — Mermaid diagrams   [current]
- [ ] Read mermaid's licence from its own `LICENSE`; vendor one pinned `mermaid.min.js` under
  `docs/` and load it with `extra_javascript`; add the `mermaid` custom fence to
  `pymdownx.superfences`. Confirm in a built page that no request goes to unpkg — files:
  `mkdocs.yml`, `docs/assets/…`
- [ ] Diagrams, left to right, short labels, `layout: dagre` in frontmatter, prose kept beside each:
  the §2 loop with its back-edges; the §8 backlog → plan → changelog lifecycle with targets and
  triage; the §6 hook path (`PreToolUse` guards, then `PostToolUse` check) — files:
  `docs/methodology.md`
- [ ] View each on the site and on GitHub at desktop width and 375 px before
  the PR is ready
- [ ] Delete the backlog item; `[Unreleased]` Added line — files: `docs/backlog.md`, `CHANGELOG.md`
- Acceptance: diagrams render on both; no third-party script on the site; strict build clean;
  reviewer run.

## Stage 4 — Cut 0.5.0 and close the plan   [not started]
On the maintainer's go only.
- [ ] Review `[Unreleased]` as a whole; turn it into `## [0.5.0] - YYYY-MM-DD`; raise
  `plugin.json`'s `version` to 0.5.0 in the same commit — files: `CHANGELOG.md`,
  `plugin/.claude-plugin/plugin.json`
- [ ] Close the plan with `close-plan` (status done, clear the pointer, archive) — files:
  `docs/plans/…`, `docs/backlog.md`
- [ ] After merge: tag `v0.5.0` on the merge commit; check the deploy run and the live site
- Acceptance: tag on GitHub; `claude plugin update minnel@minnel` moves an install to 0.5.0.

---

## Deviations
- 2026-11-24 — Stage 1: the release skill suggests a version from the commits' types
  (Conventional Commits: `feat` minor, `fix` patch, a breaking change major) rather than from
  backlog tags, since `debt` is not a commit type. §8 keeps the `debt`/`chore` rule as Minnel's own.
- 2026-11-24 — One PR for the release instead of one per stage. The site deploys on every merge
  to `main`, so a single merge publishes 0.5.0's docs together; the stages build on each other
  anyway. A draft PR opens after Stage 1 so the Mermaid stage can be checked on GitHub.

## Decisions
- 2026-11-24 — Release targets are an inline `target: X.Y.Z` tag on Next items — keeps Next one
  ordered list and changes Appendix F by one line.
- 2026-11-24 — Self-host a pinned mermaid.js — Zensical otherwise loads `mermaid@12` from unpkg with
  no integrity hash.
- 2026-11-24 — Version 0.5.0, not 0.4.1 — `[Unreleased]` already holds a `feat`.

## Verification (whole plan)
Per stage: the consistency hook on each edited file (Check E for every pair touched), `zensical
build --strict`, and for plugin changes `plugin/scripts/tests/guards.sh` plus both `claude plugin
validate` runs; one reviewer run per branch. At the end: the post-merge deploy run passes, the site
shows the diagrams with no unpkg request, and an install updates to 0.5.0.
