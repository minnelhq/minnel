---
name: project-plugin-minnel
description: The shipped plugin (Minnel, in plugin/) and the consistency hook's Check E that pins it to the appendices — what to check and the blind spots found
metadata:
  type: project
---

The methodology ships as a plugin named **Minnel** in `plugin/`, listed by a root
`.claude-plugin/marketplace.json` (install `minnel@minnel`). Built on branch `feat/plugin`
(plan archived as `docs/plans/archive/plugin-build.md`, first reviewed 2026-11-23). The plugin
files are the source; the appendices keep embedded copies, and Check E in
`.claude/hooks/docs-consistency.sh` flags drift between each pair (A, B, both C guards, D–H, J–N,
and `templates/CLAUDE.template.md` vs the scaffold's copy).

**Why:** document and plugin ship under one version and one CHANGELOG, so drift between an
appendix and its plugin file is now a defect class like a dangling §N.

**How to apply:**
- Plugin skills and agents are namespaced: a skill runs as `/minnel:<name>`, never bare
  `/<name>` (skills docs, "plugin skills are namespaced as /plugin-name:skill-name", checked
  2026-11-23). Grep tracked prose for bare `/scaffold`, `/plan` etc. used to mean the *plugin*
  skill; the first review found both forms mixed.
- Check E normalisers can hide drift. The first review (2026-11-23) found three gaps: a field
  added after `hooks:` in Appendix B, an `allowed-tools` line added to an appendix command, and a
  plugin skill losing `disable-model-invocation: true` all passed. Fixed the same day:
  `drop_hooks` ends at the first unindented line, `skill_fm` became `drop_skill_keys` (a
  plugin-side deny-list), and every skill's frontmatter must carry the flag. Re-test after any
  normaliser edit. Later on 2026-11-23 the J–N appendix frontmatters gained
  `disable-model-invocation: true` and `drop_skill_keys` stopped stripping it, so the flag is
  compared within each J–N pair as well as by the every-skill check; if someone re-adds it to the
  deny-list, an appendix losing the flag would pass again. Appendix H's example version headings are not compared either (hook header,
  limitation 4; confirmed by mutation 2026-11-23), so a heading-format change there needs a manual
  grep. Prose around the D and G skeletons in the scaffold templates is still not
  compared (a listed limitation).
- Mutation-test Check E in a `git archive <branch> | tar -x` copy in the scratchpad, running the
  hook with `CLAUDE_PROJECT_DIR` set to that copy; never mutate the shared checkout.
- With `plugin/scripts/tests/guards.sh` and `claude plugin validate` in the repo, "no build or
  test step" carriers (CLAUDE.md intro, DoD preamble and its HTML comment, README Dogfooding) go
  stale. Reconciled 2026-11-23, with a DoD plugin item; check new prose doesn't reintroduce them.
- `hooks.json` command paths: the plugins reference quotes the root
  (`"\"${CLAUDE_PLUGIN_ROOT}\"/scripts/x.sh"`); an unquoted root breaks on a path with a space
  and the guard then fails open silently.

- ADR 0004 (`docs/design/0004-ship-the-plugin-from-this-repo.md`, drafted 2026-11-23) records
  the plugin decisions; the plan's Decisions section is its source. Its first draft miscounted
  the PAIRS rows (said 15 appendix pairs plus the template; it was 14 plus the template). Count
  the heredoc rows yourself whenever prose states a pair count, and prefer prose with no count,
  since every new row strands one.
- "Has run on this repository" claims (packaging doc, "Install this plugin"; ADR 0004
  Consequences; README Dogfooding) must match what `.claude/settings.json` wires, not what the
  plugin ships. From 2026-11-23 (branch reconcile-claude-minnel-config) `.claude/settings.json`
  enables `minnel@minnel` from the GitHub marketplace, so the rituals and both guards run here;
  re-check the packaging doc's and ADR 0004's "less use" lists as that use accrues. The
  pieces-with-less-use list lives in two places; a change to one strands the other.
- Dogfooding caveat: a `github` marketplace source runs the published default branch, not the
  worktree's `plugin/`. A branch that edits a plugin skill is not exercised by `/minnel:<skill>`
  here until it merges, a release raises the version (pinned since 0.4.0), the marketplace is
  refreshed and the install is updated (`claude plugin update`). Don't accept "ran it here" as evidence for a
  plugin edit on the same branch.
  The lag also bites "has had use" claims: on 2026-11-23 (claude/adr-0004-catch-up) every cached
  install under `~/.claude/plugins/cache/minnel/minnel/` predated PR #25, so the guards that had
  "run here" were the old phrase-matching ones; the segmenter rewrite shipping in 0.4.0 had run
  only in `guards.sh`. Check the cache's `bash-guard.sh` (or `installed_plugins.json`'s
  `gitCommitSha`) before accepting that a guard version has had live use.
- Before PR #23 this repo's `.claude/` held the five ritual commands and the reviewer, but never
  a bash or git guard (`.claude/hooks/` only ever had `docs-consistency.sh`; checked with
  `git log --diff-filter=AD -- '.claude/hooks/*'` on 2026-11-23). Prose saying the repo "kept its
  own copies of the guards" is false.
- Since 2026-11-23 the repo has no reviewer of its own: you are `minnel:code-reviewer`, and this
  memory moved from `.claude/agent-memory/code-reviewer/` to `minnel-code-reviewer/` (the folder
  Claude Code uses for the namespaced agent; observed, not documented). The repo-only checks the
  old tailored prompt carried (hook-script safety, CI least privilege, the Zensical and plugin
  commands) are Definition of Done items now, so read the DoD every review. The installed copy
  is whatever the last release pinned, so a merged reviewer change reaches you only after the next
  release, a marketplace refresh and `claude plugin update`.
- Claims in prose that go beyond the plan's recorded mechanics (e.g. how an unversioned plugin
  updates) need their own dated source; the plan's "Plugin mechanics" decision is the verified set.
- Install minimums (Claude Code CHANGELOG, read 2026-11-23): in-session
  `/plugin install <p> --marketplace <src>` is 2.1.275; shell `claude plugin install --marketplace`
  is 2.1.292. The validator's one-step advice quotes 2.1.275 (the slash form). Any doc giving a
  minimum for the shell form must say 2.1.292; grep the raw changelog, it outranks `--help`.

- **Pinned version (from 0.4.0).** Branch claude/stage-6 (2026-11-23) set `"version": "0.4.0"`.
  Per the plugins docs ("Versions and updates", loading.md, read 2026-11-23) the manifest version
  wins over the commit SHA, so every install, this repo's own included, keeps its cached copy until
  the string changes. `/minnel:release` does not touch `plugin.json`, so the Definition of Done
  has a "Release (when cutting one)" item: `version` equals the new CHANGELOG version. (It first
  sat in the Plugin item, whose trigger a release commit doesn't fire; moved 2026-11-23.) Auto-update
  is off by default for third-party marketplaces (discover-plugins docs, 2026-11-23); reject prose
  saying installs update by themselves. **Corrected 2026-11-23 (claude/install-update-wording):**
  `claude plugin marketplace update <mkt>` only refreshes the catalogue (observed: installs stayed
  on the old cached copy); `claude plugin update <plugin>@<mkt>` moves the install, scope
  auto-detected from v2.1.281, and the new version loads next session or after `/reload-plugins`
  (`--help` on v2.1.330 says "restart required to apply"). Reject prose saying a marketplace
  update alone moves an install; I had accepted that wording in the Stage 6 review. Order matters:
  refresh the catalogue first. Also observed 2026-11-23: `installed_plugins.json` holds a
  project-scope `minnel@minnel` entry per worktree path plus a user entry, so "the install" in
  dogfooding prose is several installs; one `plugin update` may not move them all (unverified).
  Check dogfooding prose doesn't imply merged plugin edits run here before a release.
  From 2026-11-23 (claude/wrap-0.4.0) ADR 0004 and the DoD say to raise `version` only in the
  release commit. Evidence it happened: the user-scope entry in `installed_plugins.json` moved to
  "0.4.0" at 96e9862, a minute before the release commit 01b414a (plugin content identical to
  v0.4.0). Reject rule prose saying `claude plugin update` alone moves an install (it needs the
  catalogue refresh first). Unverified gap: a *fresh* install clones `main` at HEAD, so it gets
  unreleased plugin commits under the old version label whatever the bump rule says.
- **"Read-only" reviewer claims.** The sub-agents docs say `memory:` auto-enables Read, Write and
  Edit (observed too: this reviewer's session has Write and Edit), and `Bash` can write anyway.
  So "(no Edit/Write)" in §4's roster and any "can't change the code" wording is false; only the
  prompt's instruction restrains it. Backlog item opened 2026-11-23.

See [[feedback-hook-script-review]], [[project-plugin-rules-claim]], [[feedback-recurring-defects]].
