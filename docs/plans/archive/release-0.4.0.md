# Plan: Prepare release 0.4.0   (approved 2026-11-23)

**Status:** done (2026-11-23) — Stages 0–6 complete: `main` is ready for the maintainer to cut
0.4.0 with `/minnel:release 0.4.0` and the tag, which follow this plan's last merge.

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
before merge, re-run as the working agreement says (none of these is trivial). When a stage
ships a backlog item, delete its line from `docs/backlog.md` in that stage's commit and move the
outcome to `[Unreleased]` (§8).

---

## Stage 0 — Record the plan   [done]
- [x] Commit this file as `docs/plans/release-0.4.0.md`, and point `## Now (this plan)` in
      `docs/backlog.md` at it — on `claude/backlog-triage-8e25d5`, with the triage commit, so
      one merge carries both.
- Acceptance: the merged backlog's Now section names this plan.

## Stage 1 — Guards: command position, variants, and the tripwire claim   [done]
Decision (2026-11-23): fix the variants *and* say plainly they catch slips.
- [x] Command patterns (`rm`, `git add`, `git commit`, `git push`) match only at a command
      position: line start or after `;`, `&&`, `||`, `|`, `(`, `$(`, past leading `sudo`, `env`,
      `command`, `xargs` and `VAR=value` words and their options, and after `-exec`; `rm` also
      as `\rm` or a path such as `/bin/rm`. Other wrappers (`nohup`, `nice`, `timeout`,
      `time`) are accepted misses. Quoted strings are stripped before matching, after the
      quoted-dot check for `git add`. Flag checks scan only to the end of their own command
      (the next `;`, `&`, `&&`, `||`, `|` or newline); backticks and `{` are accepted misses. So a grep pattern, a heredoc body line that doesn't
      start a command, a commit message or `&& git log --all` no longer trips them. Argument-level
      patterns (`DROP TABLE`, which only ever appears inside an argument) keep matching across
      the whole command, quotes included. — files: `plugin/scripts/bash-guard.sh`,
      `plugin/scripts/git-guard.sh`
- [x] `bash-guard`: `rm` with recursive and force in any form (`-rf`, `-fr`, `-r -f`,
      `--recursive --force`); `git push -f` beside `--force`, also after git's global options;
      and decide whether `--force-with-lease`, which today's pattern blocks, stays blocked.
- [x] `git-guard`: `git add` with `-A` in a flag cluster (`-Av`), `-u`/`--update`, `:/`, `.`, `..`,
      `./`, `.;` and quoted dots; `git commit` with `a` inside a short-flag cluster (`-qam`,
      `-vam`) but not `--amend`; `push` after global options (`-C <dir>`, `-c k=v`,
      `--git-dir=`, `--work-tree=`, `--no-pager`).
- [x] Add every case above to `plugin/scripts/tests/guards.sh`, blocks and passes alike,
      including the two false positives seen on 2026-11-23 (a `grep` pattern and a heredoc).
      Add each accepted miss (such as `sh -c '…'` with the command inside quotes) as a
      documented pass, so the "catch slips" claim is pinned by a test.
- [x] Copy the scripts into Appendix C (`docs/appendices/hooks.md`); Check E compares them.
- [x] Say they catch slips, not a determined command, wherever the docs claim protection. Find
      them with `git grep -nE "backstop|confidently|cannot forget|guard against"` and read
      each guard mention: at least Appendix C's intro, §11's "Deterministic guards" and
      "Secret hygiene" paragraphs (the latter calls the git-guard a "backstop"), §6's guard
      bullet, §9's git-guard bullet, and the packaging doc's guard bullet
      (`docs/packaging-as-a-plugin.md`).
- [x] Quote `$CLAUDE_PROJECT_DIR` in hook commands: Appendix C's JSON, Appendix B's frontmatter
      hook (`docs/appendices/subagents.md`), `.claude/settings.json`, the §6 prose that
      recommends the prefix, and the hook-script item in `.claude/rules/definition-of-done.md`.
- [x] Delete the guards and quoting lines from the backlog. Record both in `[Unreleased]`:
      Appendix C's guards are already released, so their change is *Fixed*; the plugin side folds
      into the existing *Added* entry (the Definition of Done's pre-release clause).
- Acceptance: `plugin/scripts/tests/guards.sh` passes with the new cases; Check E reports no
  drift; `claude plugin validate plugin` and `claude plugin validate .` give no warning `main`
  doesn't; `sh -n` passes on each script; no doc claims a guard stops a determined command.

## Stage 2 — ADR 0004 catches up   [done]
- [x] Add a dated amendment to ADR 0004's Consequences: this repo runs the plugin's rituals,
      guards and reviewer (since PR #23), with no repo copies; the two copies are now appendix
      and plugin only. Update the `rm -rf` consequence to what Stage 1 made of it, and drop the
      "§10 note is on the backlog" consequence, which §10 now carries.
      — files: `docs/design/0004-ship-the-plugin-from-this-repo.md`
- [x] Revisit the "less use" lists in the ADR and `docs/packaging-as-a-plugin.md`: the guards
      have now run here; `test-writer` and the scaffold have not.
- Acceptance: every Consequence states what's true on `main`; the ADR and packaging doc agree.

## Stage 3 — Reviewer: personal data and licences   [done]
- [x] Add two checks to the reviewer's list: no personal data (real names, contact details,
      identifiers or figures) in code, fixtures, docs or commit messages unless the project's
      purpose needs it; and a new dependency's licence read from its own metadata, stated, and
      flagged if copyleft or non-commercial. — files: `plugin/agents/code-reviewer.md`, Appendix A
      in `docs/appendices/subagents.md`
- [x] Mention the checks where the docs list what the reviewer checks (§4's table if it does).
- [x] Carry this repo's narrower re-run rule (2026-11-23) to adopters: re-run after a Critical
      fix, a Warning fix that changes code or published guidance, or commits other than fixes
      for its findings, aimed at the new commits; check other fixes by hand. Change the
      reviewer's `description` with Appendix A, §7's review bullet, and
      `templates/CLAUDE.template.md` with the scaffold's copy; and this repo's `add-section`
      skill, whose "clear any Critical or Warning" reads as requiring a re-run.
- [x] Record in `[Unreleased]`.
- Acceptance: Check E reports no drift between Appendix A and the agent; the plugin validates.

## Stage 4 — Retitle as Minnel   [done]
Decision (2026-11-23): "Minnel: a file-first operating model for Claude Code".
- [x] Retitle: `README.md`, `CLAUDE.md`, `mkdocs.yml` `site_name`, `docs/index.md`,
      `docs/methodology.md`, and the companion lines in `docs/worked-example.md` and
      `docs/packaging-as-a-plugin.md`. The 0.1.0 changelog entry keeps its historical title.
- [x] Reword the README's Status paragraph so "the document" and "the plugin" read as one
      Minnel (the tagged-release clause stays until Stage 6).
- [x] Delete the title line from the backlog; record in `[Unreleased]`.
- Acceptance: `git grep -n "A File-First Operating Model" -- . ':!docs/plans/archive'
  ':!.claude/agent-memory' ':!docs/plans/release-0.4.0.md'` finds only the 0.1.0 entry (and any
  `[Unreleased]` line naming the old title); `zensical build --strict` passes; the site's URL is
  unchanged.

## Stage 5 — The plugin's own README, icon and network declaration   [done]
- [x] `plugin/README.md` (40 words or more): what Minnel does, its parts (two agents, three guard
      hooks, six skills), the install commands, and links to the methodology and to the
      packaging doc's "Install this plugin" section for the rest, rather than restating it.
      Keep the two-step `marketplace add` and `install minnel@minnel` form unless
      `claude plugin install --help` confirms a one-step form; the validator's one-step advice
      concerns the root `README.md` and needs Claude Code 2.1.275 or later, so state that
      minimum wherever the one-step form appears.
- [x] Draft a square PNG icon, 1024 px, from a shape-only SVG (no font, so no font licence),
      rendered with ImageMagick; commit the PNG at `plugin/.claude-plugin/icon.png` and the SVG
      source at `assets/minnel-icon.svg`. The maintainer may replace it before it is first used
      anywhere.
- [x] Declare `network.hosts` in `plugin.json` as an empty list: the guards, skills and agents
      name no host (re-check with a grep of `plugin/` for `curl`, `gh `, `fetch` and `http`;
      `plugin.json`'s own `homepage` and `repository` URLs are metadata, not network calls).
      Check the field's shape in the current plugin-manifest docs first.
- [x] Record in `[Unreleased]`.
- Acceptance: `claude plugin validate plugin --profile directory --strict` fails on nothing but
  the missing `version`; the icon is square, 512–2048 px, PNG, under 2 MB.

## Stage 6 — Release readiness   [done]
- [x] Set `"version": "0.4.0"` in `plugin/.claude-plugin/plugin.json` (ADR 0004: the release that
      first ships the plugin sets it), and drop the README's "not yet in a tagged release".
- [x] Appendix D and the scaffold's plans README: when each stage merges on its own branch, the
      stage's last commit names the next stage, so the plan on `main` is true after the merge.
      — files: `docs/appendices/skeletons.md`, `plugin/skills/scaffold/templates/plans-README.md`
- [x] Add the one-step install to "Install this plugin" in `docs/packaging-as-a-plugin.md`, with
      its minimum (2.1.292 for `claude plugin install --marketplace`, 2.1.275 for the in-session
      form), matching `plugin/README.md`.
- [x] Re-read `[Unreleased]` against the merged stages: every user-facing change listed once, in
      the right Keep a Changelog category.
- [x] Run the full check: `guards.sh`, both `claude plugin validate` runs (the directory profile
      now clean), `zensical build --strict`, and Check E across the repo.
- [x] Hand over: the maintainer runs `/minnel:release 0.4.0` and tags; then close this plan.
- Acceptance: every check passes on the release branch; the guards, quoting and title lines are
  gone from Next, and `[Unreleased]` records each stage's outcome.

---

## Deviations
- 2026-11-23, Stage 1 — Both guards share one parser, `command-segments.awk`, a third
  Appendix C file with its own Check E pair, rather than each script carrying a copy.
- 2026-11-23, Stage 1 — Backticks, `{` and the wrappers `nohup`, `nice`, `timeout` and `time`
  are handled, not accepted misses: the parser ends a command at the first two and skips the
  rest like `sudo`.
- 2026-11-23, Stage 1 — A heredoc's body is skipped as data, so a body line that starts with a
  command no longer trips a guard and an apostrophe in a body can't hide later commands. A script
  fed to a shell as a heredoc (`bash <<EOF`) becomes an accepted miss.
- 2026-11-23, Stage 1 — CI now runs `guards.sh` under mawk and gawk on every PR and push to
  `main` (`.github/workflows/guards.yml`); both passed 101/101 without a parser change.
- 2026-11-23, Stage 2 — No changelog entry: the ADR is a design record, not a published doc, and
  the `[Unreleased]` line for "Install this plugin" already says the section names which pieces
  have had less use, which stays true.
- 2026-11-23, Stage 2 — The guards stay on the "less use" lists, with a qualifier, rather than
  coming off: they have run here only since PR #23, and only in their pre-Stage 1 form; the rules
  0.4.0 ships have run only in `guards.sh`.
- 2026-11-23, Stage 3 — No doc lists the reviewer's checks (§4's table names its tools and
  model only), so §11's secret hygiene gained a clause naming the personal-data check instead.
  The reviewer now also reads `git log main..HEAD`, since the personal-data check covers commit
  messages. The adopter rule says "code or published docs" where this repo's names plugin code, the
  template or a published doc. Appendix O's Secrets item names the reviewer's check too, to
  match §11.
- 2026-11-23, Stage 4 — The README's `plugin/` line and `CLAUDE.md`'s opening no longer call the
  plugin alone "Minnel",
  and the backlog's deploy item no longer points at the deleted title item. The worked example's
  "Last updated" moves to 2026-11-23 with its companion line.
- 2026-11-23, Stage 4 — At the maintainer's request the stage also carries a house-voice pass
  (now `.claude/rules/house-voice.md`) over the methodology, README, worked example, packaging doc and site home page, and the style guide's scope now names the
  packaging doc. The pass rewords §11's heading and one packaging-doc heading; the
  site's anchors for both are unchanged, and no link targets either. `[Unreleased]` is rewritten
  shorter, at the maintainer's request, with the same changes listed.
- 2026-11-23, Stage 4 — The house-voice guide moves from `docs/style.md` to a path-scoped rule,
  `.claude/rules/house-voice.md`, so it loads whenever Claude reads or edits a Markdown file
  rather than only when something points Claude at it. It now also covers changelog entries and
  plan and backlog notes. Repo plumbing, so no changelog line.

- 2026-11-23, Stage 5 — `claude plugin install --help` confirms a one-step form
  (`--marketplace <owner/repo>`), so `plugin/README.md` leads with it and keeps the two-step form
  for earlier versions. Claude Code's changelog puts the CLI flag at 2.1.292; 2.1.275, the
  validator's figure, added the in-session `/plugin install … --marketplace`, and the README
  states both. With a README of its own in `plugin/`, the directory profile no longer falls back
  to the root README.
- 2026-11-23, Stage 5 — The manifest reference gives `"network": {"hosts": [...]}`, needing Claude
  Code 2.1.328 or later, and says the field neither allows nor blocks a host. So the changelog
  says the plugin *declares* it reaches none. The strict run still prints "Hosts not read for:
  hooks (1), skills (6)" as information, not a warning. The icon is rendered at 8-bit depth.
- 2026-11-23, Stage 6 — Two steps added from the Stage 5 wrap. Stages 4 and 5 each left the
  status reading "done, awaiting review and merge", which was stale once they merged, so Appendix D
  now says a stage's last commit names the next stage. The Stage 5 review found the packaging doc
  gives only the two-step install. The same review's other points went to the house-voice scope
  (now covering `plugin/README.md`) and the backlog (the reviewer's "read-only" wording).
- 2026-11-23, Stage 6 — The plan closes in Stage 6's own branch, before the release, so the plan
  on `main` is true once that branch merges (the Appendix D rule this stage added). The Goal is a
  `main` ready to cut 0.4.0; cutting it stays out of scope.

## Decisions
- 2026-11-23 — Retitle as "Minnel: a file-first operating model for Claude Code" — one name across
  plugin, site and docs; the description survives as the subtitle.
- 2026-11-23 — Ship once the name is decided — steps outside the repository run in parallel and
  don't gate the release.
- 2026-11-23 — Guards: match at command position, cover the variants, and say they catch slips
  — fixes the false positives as well as the misses, without promising more than a pattern can.
- 2026-11-23 — Draft the icon here, shape-only, replaceable by the maintainer.
- 2026-11-23 — `git push --force-with-lease` passes the bash-guard and reaches the git guard's
  push prompt — it refuses to overwrite work it hasn't seen, and every push is asked about anyway.
- 2026-11-23 — `DROP TABLE` stays matched anywhere, so a commit message that mentions it is
  blocked — an accepted false positive, pinned in `guards.sh`.
- 2026-11-23 — Without `command-segments.awk` beside them, the bash and git guards block every
  `Bash` call and say why — a guard copied without its parser would otherwise pass everything
  silently, unlike a missing `jq`, which is an environment gap the packaging doc already names.
- 2026-11-23 — Icon: the maintainer chose three chevrons, stages moving forward with the last in
  amber, over drafts built on documents, checklists, a monogram, a staircase and rings.
- 2026-11-23 — Keep `plugin.json`'s `version` and raise it at every release — ADR 0004 ties it to
  the changelog's version. A manifest version pins installs to the cached copy, so a fix merged
  between releases reaches installs only at the next one; the Definition of Done now names the
  step, since `/minnel:release` doesn't touch `plugin.json`.

## Verification (whole plan)
On the Stage 6 branch: `plugin/scripts/tests/guards.sh`; `claude plugin validate plugin
--profile directory --strict` and `claude plugin validate .`; `zensical build --strict`; touching
any doc runs `.claude/hooks/docs-consistency.sh`, including Check E; a `minnel:code-reviewer`
pass with no Critical finding; and, in a live session with `claude --plugin-dir ./plugin`, a
`grep` for `rm -rf` passes while `rm -fr /tmp/x` and `git -C . push` are blocked or asked.

Done 2026-11-23 on `claude/stage-6`: every item passed. The live check ran `claude -p` in a
scratch git repo with no remote, loading only `--plugin-dir ./plugin` (`--setting-sources local`,
so the installed copy stayed out): the `grep` ran, `rm -fr ./x` was blocked by the bash guard, and
`git -C . push` reached the git guard's push prompt, which a `-p` run refuses.

<!-- Completed 2026-11-23 and archived under docs/plans/archive/ (§3) in Stage 6's branch, so the
plan on main is true at merge. The release and tag follow. -->
