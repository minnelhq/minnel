# Plan: Prepare release 0.4.0   (approved 2026-11-23)

**Status:** in progress — Stage 1 of 6

## Context
`[Unreleased]` adds Minnel, the plugin, so the next release (0.4.0, a minor) is the first tagged
release that ships it. The triage of 2026-11-23 put six pieces of work in it: the
guards must stop over-promising, hook commands must survive paths with spaces, the methodology
takes the plugin's name, the reviewer gains personal-data and licence checks, ADR 0004 catches up
with this repo running its own plugin, and the plugin gets its own README, icon and network
declaration. `/minnel:release` touches neither `plugin.json`'s `version` nor the README's "not yet in a
tagged release", so the last stage does both. The maintainer cuts the release; this plan gets it ready.

## Goal
`main` is ready for the maintainer to cut 0.4.0: every 0.4.0 item merged and reviewed, `[Unreleased]`
complete, and `claude plugin validate plugin --profile directory --strict` passing clean.

## Out of scope
- Cutting the release itself (the maintainer runs `/minnel:release 0.4.0` and tags).
- Securing the name outside the repository: the maintainer's steps, in parallel; the release
  doesn't wait for them.
- Submitting the plugin anywhere, deploy-on-push, and the other Next items.
- Renaming the GitHub repository.

## How the stages run
One branch and PR per stage, in order, from an up-to-date `main`, because each stage edits
`CHANGELOG.md [Unreleased]`. Each branch gets a `minnel:code-reviewer` run on its final diff
before merge, re-run as the working agreement says (none of these is trivial). When a stage ships a backlog item, delete its line from `docs/backlog.md`
in that stage's commit and move the outcome to `[Unreleased]` (§8).

---

## Stage 0 — Record the plan   [done]
- [x] Commit this file as `docs/plans/release-0.4.0.md`, and point `## Now (this plan)` in
      `docs/backlog.md` at it — on `claude/backlog-triage-8e25d5`, with the triage commit, so
      one merge carries both.
- Acceptance: the merged backlog's Now section names this plan.

## Stage 1 — Guards: command position, variants, and the tripwire claim   [not started]
Decision (2026-11-23): fix the variants *and* say plainly they catch slips.
- [ ] Command patterns (`rm`, `git add`, `git commit`, `git push`) match only at a command
      position: line start or after `;`, `&&`, `||`, `|`, `(`, `$(`, past leading `sudo`, `env`,
      `command`, `xargs` and `VAR=value` words, and after `-exec`; `rm` also as `\rm` or a
      path such as `/bin/rm`. Quoted strings are stripped before matching, after the
      quoted-dot check for `git add`. A grep pattern, a heredoc body line that doesn't start a
      command, a commit message or `&& git log --all` no longer trips them. Argument-level
      patterns (`DROP TABLE`, which only ever appears inside an argument) keep matching across
      the whole command, quotes included. — files: `plugin/scripts/bash-guard.sh`,
      `plugin/scripts/git-guard.sh`
- [ ] `bash-guard`: `rm` with recursive and force in any form (`-rf`, `-fr`, `-r -f`,
      `--recursive --force`); `git push -f` beside `--force`, also after git's global options;
      and decide whether `--force-with-lease`, which today's pattern blocks, stays blocked.
- [ ] `git-guard`: `git add` with `-A` in a flag cluster (`-Av`), `-u`/`--update`, `:/`, `.`, `..`,
      `./`, `.;` and quoted dots; `git commit` with `a` inside a short-flag cluster (`-qam`,
      `-vam`) but not `--amend`; `push` after global options (`-C <dir>`, `-c k=v`,
      `--git-dir=`, `--work-tree=`, `--no-pager`).
- [ ] Add every case above to `plugin/scripts/tests/guards.sh`, blocks and passes alike,
      including the two false positives seen on 2026-11-23 (a `grep` pattern and a heredoc).
      Add each accepted miss (such as `sh -c '…'` with the command inside quotes) as a
      documented pass, so the "catch slips" claim is pinned by a test.
- [ ] Copy the scripts into Appendix C (`docs/appendices/hooks.md`); Check E compares them.
- [ ] Say they catch slips, not a determined command, wherever the docs claim protection. Find
      them with `git grep -nE "backstop|confidently|cannot forget|guard against"` and read
      each guard mention: at least Appendix C's intro, §11's "Deterministic guards" and
      "Secret hygiene" paragraphs (the latter calls the git-guard a "backstop"), §6's guard
      bullet, §9's git-guard bullet, and the packaging doc's guard bullet
      (`docs/packaging-as-a-plugin.md`).
- [ ] Quote `$CLAUDE_PROJECT_DIR` in hook commands: Appendix C's JSON, Appendix B's frontmatter
      hook (`docs/appendices/subagents.md`), `.claude/settings.json`, the §6 prose that
      recommends the prefix, and the hook-script item in `.claude/rules/definition-of-done.md`.
- [ ] Delete the guards and quoting lines from the backlog. Record both in `[Unreleased]`:
      Appendix C's guards shipped in 0.3.x, so their change is *Fixed*; the plugin side folds
      into the existing *Added* entry (the Definition of Done's pre-release clause).
- Acceptance: `plugin/scripts/tests/guards.sh` passes with the new cases; Check E reports no
  drift; `claude plugin validate plugin` and `claude plugin validate .` give no warning `main`
  doesn't; `sh -n` passes on each script; no doc claims a guard stops a determined command.

## Stage 2 — ADR 0004 catches up   [not started]
- [ ] Add a dated amendment to ADR 0004's Consequences: this repo runs the plugin's rituals,
      guards and reviewer (since PR #23), with no repo copies; the two copies are now appendix
      and plugin only. Update the `rm -rf` consequence to what Stage 1 made of it, and drop the
      "§10 note is on the backlog" consequence, which §10 now carries.
      — files: `docs/design/0004-ship-the-plugin-from-this-repo.md`
- [ ] Revisit the "less use" lists in the ADR and `docs/packaging-as-a-plugin.md`: the guards
      have now run here; `test-writer` and the scaffold have not.
- Acceptance: every Consequence states what's true on `main`; the ADR and packaging doc agree.

## Stage 3 — Reviewer: personal data and licences   [not started]
- [ ] Add two checks to the reviewer's list: no personal data (real names, contact details,
      identifiers or figures) in code, fixtures, docs or commit messages unless the project's
      purpose needs it; and a new dependency's licence read from its own metadata, stated, and
      flagged if copyleft or non-commercial. — files: `plugin/agents/code-reviewer.md`, Appendix A
      in `docs/appendices/subagents.md`
- [ ] Mention the checks where the docs list what the reviewer checks (§4's table if it does).
- [ ] Record in `[Unreleased]`.
- Acceptance: Check E reports no drift between Appendix A and the agent; the plugin validates.

## Stage 4 — Retitle as Minnel   [not started]
Decision (2026-11-23): "Minnel: a file-first operating model for Claude Code".
- [ ] Retitle: `README.md`, `CLAUDE.md`, `mkdocs.yml` `site_name`, `docs/index.md`,
      `docs/methodology.md`, and the companion lines in `docs/worked-example.md` and
      `docs/packaging-as-a-plugin.md`. The 0.1.0 changelog entry keeps its historical title.
- [ ] Reword the README's Status paragraph so "the document" and "the plugin" read as one
      Minnel (the tagged-release clause stays until Stage 6).
- [ ] Delete the title line from the backlog; record in `[Unreleased]`.
- Acceptance: `git grep -n "A File-First Operating Model" -- . ':!docs/plans/archive'
  ':!.claude/agent-memory'` finds only the 0.1.0 entry; `zensical build --strict` passes; the
  site's URL is unchanged.

## Stage 5 — The plugin's own README, icon and network declaration   [not started]
- [ ] `plugin/README.md` (40 words or more): what Minnel does, its parts (two agents, three guard
      hooks, six skills), the install commands, and links to the methodology and to the
      packaging doc's "Install this plugin" section for the rest, rather than restating it.
      Check the current install form first: `claude plugin validate .` suggests a one-step
      `/plugin install … --marketplace …`; if it holds, update the packaging doc to match.
- [ ] Draft a square PNG icon, 1024 px, from a shape-only SVG (no font, so no font licence),
      rendered with ImageMagick; commit the PNG at `plugin/.claude-plugin/icon.png` and the SVG
      source at `assets/minnel-icon.svg`. The maintainer may replace it before it is first used
      anywhere.
- [ ] Declare `network.hosts` in `plugin.json` as an empty list: the guards, skills and agents
      name no host (re-check with a grep of `plugin/` for `curl`, `gh `, `fetch` and `http`).
      Check the field's shape in the current plugin-manifest docs first.
- [ ] Record in `[Unreleased]`.
- Acceptance: `claude plugin validate plugin --profile directory --strict` fails on nothing but
  the missing `version`; the icon is square, 512–2048 px, PNG, under 2 MB.

## Stage 6 — Release readiness   [not started]
- [ ] Set `"version": "0.4.0"` in `plugin/.claude-plugin/plugin.json` (ADR 0004: the release that
      first ships the plugin sets it), and drop the README's "not yet in a tagged release".
- [ ] Re-read `[Unreleased]` against the merged stages: every user-facing change listed once, in
      the right Keep a Changelog category.
- [ ] Run the full check: `guards.sh`, both `claude plugin validate` runs (the directory profile
      now clean), `zensical build --strict`, and Check E across the repo.
- [ ] Hand over: the maintainer runs `/minnel:release 0.4.0` and tags; then close this plan.
- Acceptance: every check passes on the release branch; the guards, quoting and title lines are
  gone from Next, and `[Unreleased]` records each stage's outcome.

---

## Deviations

## Decisions
- 2026-11-23 — Retitle as "Minnel: a file-first operating model for Claude Code" — one name across
  plugin, site and docs; the description survives as the subtitle.
- 2026-11-23 — Ship once the name is decided — steps outside the repository run in parallel and
  don't gate the release.
- 2026-11-23 — Guards: match at command position, cover the variants, and say they catch slips
  — fixes the false positives as well as the misses, without promising more than a pattern can.
- 2026-11-23 — Draft the icon here, shape-only, replaceable by the maintainer.

## Verification (whole plan)
On the Stage 6 branch: `plugin/scripts/tests/guards.sh`; `claude plugin validate plugin
--profile directory --strict` and `claude plugin validate .`; `zensical build --strict`; touching
any doc runs `.claude/hooks/docs-consistency.sh`, including Check E; a `minnel:code-reviewer`
pass with no Critical finding; and, in a live session with `claude --plugin-dir ./plugin`, a
`grep` for `rm -rf` passes while `rm -fr /tmp/x` and `git -C . push` are blocked or asked.
