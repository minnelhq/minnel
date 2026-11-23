# A File-First Operating Model for Claude Code

This repository is the methodology itself: reference docs, a CLAUDE.md template, and a Claude
Code plugin, Minnel (`plugin/`). It is a documentation project: the Markdown source has no build or
runtime; `plugin/scripts/tests/guards.sh` checks the plugin's guards. (The doc site is an
*optional* publish build — never a prerequisite for reading or editing the Markdown; see `docs/design/0002-publish-as-doc-site.md` and ADR 0003.)

## Invariants

- British English throughout (£/€ before figures); dates in ISO `YYYY-MM-DD`.
- Keep this file lean; it loads every turn. Detailed material lives under `docs/`.
- Docs live under `docs/`; the curated changelog stays at the repo root as `CHANGELOG.md`.
- The methodology must stay internally consistent: section cross-references (§N) and
  appendix letters (A–O) are load-bearing — update them together when editing.

## Layout

- `docs/methodology.md` — the main reference (narrative §1–§11).
- `docs/appendices/` — the drop-in artefacts (Appendices A–O), grouped by type; `README.md` indexes them.
- `docs/packaging-as-a-plugin.md` — plugin packaging companion.
- `templates/CLAUDE.template.md` — the starter template artefact.
- `plugin/` — the installable plugin, the appendix artefacts packaged; `.claude-plugin/marketplace.json`
  at the root lists it (ADR 0004).
- `CHANGELOG.md` — user-facing changes.
- `docs/backlog.md` — ordered candidate work (§8 / Appendix F); its `## Now (this plan)` section
  is the active-plan pointer (§3).
- `.claude/` — this repo's Definition of Done, consistency hook and skills. The rituals
  (`/minnel:plan`, `/minnel:accept`, …), the guards and `minnel:code-reviewer` come from the
  plugin, which `.claude/settings.json` enables.
- `mkdocs.yml` + `requirements.txt` — optional doc-site build with Zensical (ADRs 0002, 0003);
  `docs/` is the source.

## Conventions

- Commits: Conventional Commits, imperative mood, one concern per commit. The methodology is
  the product, so type by what changed for a reader — `feat` new guidance/artefact, `fix`
  corrected guidance, `refactor` restructuring, `chore` repo plumbing; reserve `docs` for
  trivial infra. Types mirror the backlog's feat/fix/debt/chore (§8) and pre-sort into
  CHANGELOG categories at `/minnel:release`.
- Changelog: Keep a Changelog, SemVer, ISO dates. The docs are the product, so changed guidance,
  new appendices, renumbering or re-lettering, template changes and `refactor` restructuring a
  reader would notice are all user-facing.
- Internal/private material lives in a gitignored local-notes folder; never name it or describe its
  contents in tracked files or commit messages — use neutral "local" terminology.
- Prose in the public docs follows the house voice in `docs/style.md`.
- A correction that recurs (`/minnel:retro`, `/minnel:wrap`) may mean the documented guidance is
  unclear: propose a fix to `docs/methodology.md` or the template as well as to the config.

## Working agreement

These rules govern *how* we work, not what the code does. Global working rules
(worktree hygiene, verify-before-asserting) live in `~/.claude/CLAUDE.md` and apply
alongside these; neither scope automatically overrides the other, so keep them consistent.

- **Plan before you leap.** If the approach isn't obvious — a structural refactor, or
  anything touching an invariant above — drop into plan mode and agree the approach
  before editing. This is cheap; use it freely, even for a one-file change.
- **Persist a plan only when it must outlive the session.** Write `docs/plans/<name>.md`
  when the work is multi-stage or won't finish before the context compacts or you stop —
  that is what the file is for (§3). Otherwise do the thinking and skip the file.
- **One plan file, status folded in.** Each plan is a sequence of Stages worked through
  in order; status (current stage, ticked steps, deviations, decisions) lives in the
  same file. After a compaction or restart, resume from the active plan.
- **Review before merge.** Run the `minnel:code-reviewer` subagent once on the final branch diff
  before merging to the main branch; there is no second reviewer. Re-run it after fixing a
  Critical finding, after a Warning fix that changes plugin code or public guidance, or when the
  branch gains commits beyond those fixes and the reviewer's memory, not otherwise; point a
  re-run at the new commits, not the whole branch. Check any other fix against its finding
  yourself. Skip it for a trivial branch: one that touches nothing outside `docs/backlog.md`,
  `docs/plans/` and `.claude/agent-memory/`, or only fixes typos and formatting in
  Markdown prose (not headings, link targets, code fences or front matter) without changing what
  any line claims.
- **Verify, don't assume.** Run the commands above to confirm a change works, and check
  it against the Definition of Done, before reporting it done.
