---
name: project-plugin-minnel
description: The shipped plugin (Minnel, in plugin/), Check E pinning it to the appendices, install and update mechanics, and the plugin-cannot-ship-rules claim
metadata:
  type: project
---

The methodology ships as a plugin named **Minnel** in `plugin/`, listed by the root
`.claude-plugin/marketplace.json` (install `minnel@minnel`). The plugin files are the source; the
appendices keep embedded copies, and Check E in `.claude/hooks/docs-consistency.sh` flags drift
between each pair (A, B, both C guards, D–H, J–N, P, Q, and `templates/CLAUDE.template.md` vs the
scaffold's copy). ADR 0004 records the decisions.

**Why:** document and plugin ship under one version and one CHANGELOG, so drift between an
appendix and its plugin file is a defect class like a dangling §N.

**How to apply:**
- **Namespacing.** Plugin skills run as `/minnel:<name>`, agents as `minnel:<agent>`. Grep tracked
  prose for bare `/scaffold`, `/plan` etc. meant as the *plugin* skill.
- **Check E blind spots.** Appendix H's example version headings and the prose around the D and G
  skeletons are not compared (hook header limitations), so check those by hand. `disable-model-invocation:
  true` is compared within each J–N pair and by an every-skill check; if it returns to
  `drop_skill_keys`, an appendix losing it would pass again. How to mutation-test: see
  [[feedback-plugin-review]].
- **Counts of pairs.** Prefer prose with no PAIRS count; when prose states one, count the heredoc
  rows yourself (ADR 0004's first draft miscounted).
- **"Has run here" claims** (plugin doc "Install this plugin", ADR 0004, and the repo-setup text that was README Dogfooding until the
  2026-11-25 rewrite moved it to `CONTRIBUTING.md`) must
  match what `.claude/settings.json` wires (`minnel@minnel` from GitHub since 2026-11-23), not
  what the plugin ships. The less-use list lives in the plugin doc and ADR 0004; a change to
  one strands the other.
- **Release lag.** The repo runs the published, version-pinned plugin, not the worktree's
  `plugin/`, so "ran it here" is no evidence for a plugin edit on the same branch. Before accepting
  that a guard version has had live use, check the cache's script or `installed_plugins.json`'s
  `gitCommitSha`. This applies to me too: a merged reviewer change reaches me only after a release
  and an update.
- **Reviewing a release cut (0.5.0 to 0.7.1, as of 2026-11-25).** The release commit touches only
  `CHANGELOG.md`'s heading (0.7.0 also reordered lines: prove "order only" by diffing the two
  files' `sort`ed lines, which should differ only in the heading) and `plugin.json`'s `version`.
  A body is optional: 0.5.0 and 0.6.0 had none, 0.7.0 and 0.7.1 explain a reorder or the bump
  choice; check any body's reason against the plugin diff since the last tag. The marketplace
  entry carries no version, and no other tracked file names the current one
  (`git grep -nE '0\.[0-9]+\.[0-9]+'`). Tags sit on the
  PR's *merge* commit, not the release commit (v0.5.0 = merge of #34, with fix commits after the
  cut). CHANGELOG has never had link reference definitions. 0.5.0 to 0.7.0 renamed
  `## [Unreleased]` to the version (the `/release` skill's step 5 says "in place of"); 0.7.1 kept an
  empty one above (Keep a Changelog's and §8's form). Either passes; flag only a mix within one cut.
  **Bump choice:** a `feat` touching only `.claude/hooks/docs-consistency.sh` is repo plumbing
  (the plugin's `hooks.json` ships only the three guards; no appendix embeds that hook), so a
  patch is right even though `/release` maps `feat` to minor (0.7.1, Check F).
  For coverage, diff `--stat v<prev> <branch>` and map every non-internal file to an entry: repo
  `.claude/` changes that the README describes (the `close-plan` removal in 0.6.0) slip through,
  though 0.1.0 and 0.4.0 entries counted them. Plugin DoD item applies (plugin.json touched).
  Also check `docs/backlog.md` has no `### <version>` heading left for the version being cut
  (the methodology's own `/release` step 6), and for a renamed page that the built `site/` has
  the redirect stub at the old path.
  v0.6.0 is the first tag with a GitHub Release; earlier tags have none. Joining each entry onto
  one line in the notes file is now a step in `/release` (Appendix M); check a release's notes
  against it. `gh release create --verify-tag` aborts unless the tag is already on the remote, so
  any written procedure using it needs a tag push before it (gh 2.105, 2026-11-24). Tagging prose
  must name the same commit everywhere: §8, the release skill, the DoD and the changelog line.
  Release notes and wrapped lines: `gh api markdown -f mode=gfm` renders a soft break inside a
  list item as `<br>` (2026-11-24). The release page does too: the coordinator counted 5 `<br>` in
  one wrapped v0.7.0 item and 0 after `gh release edit` with joined notes (2026-11-25, its report).
  The GitHub repo is `minnelhq/minnel` (not the folder name) for `gh api`.
  A "cut but not tagged" check must read the remote (`git ls-remote --tags origin`, `origin/main`),
  as §9 says, or a local unpushed tag hides it.
- **Install and update facts (verified 2026-11-23 on v2.1.330).**
  - `version` in `plugin.json` wins over the commit SHA, so installs keep their cached copy until it
    changes. Raise it only in the release commit (DoD Release item).
  - `claude plugin update minnel@minnel` refreshes the marketplace itself and moves the install
    (observed in an isolated `CLAUDE_CONFIG_DIR`). The shell `claude plugin marketplace update`
    only refreshes the catalogue; the in-session `/plugin` Marketplaces tab's update does move
    installs. Prose saying "the marketplace update moves nothing" must name the shell command.
  - The update moves only the most specific scope installed for the current project (from
    2.1.281); each worktree path has its own project-scope entry. The new version loads next
    session or after `/reload-plugins`.
  - Auto-update is off by default for a third-party marketplace.
  - Minimums (Claude Code CHANGELOG): in-session `/plugin install <p> --marketplace <src>` 2.1.275;
    shell `claude plugin install --marketplace` 2.1.292.
  - Unverified gap: a *fresh* install clones `main` at HEAD, so it can get unreleased plugin
    commits under the old version label.
- **"Read-only" reviewer.** `memory:` turns on Read, Write and Edit (unless auto memory is off),
  and `Bash` can write anyway, so only the prompt keeps me from fixing. Re-grep for "read-only"
  near the reviewer after any reviewer-prose edit.
- **I am `minnel:code-reviewer`.** This memory lives in `.claude/agent-memory/minnel-code-reviewer/`
  (observed, not documented). The repo-only checks (hook safety, CI least privilege, Zensical and
  plugin commands) are DoD items, so read the DoD every review.
- **A plugin can't ship `.claude/rules/`.** The plugin doc's claim was confirmed on v2.1.181
  (2026-06-19) with two controls: a plugin command fired (load control) and a project rule fired
  (mechanism control), while bundled `rules/` and `.claude/rules/` did not. The plugins reference
  omits `rules/`; the 2026-11-23 docs check adds that a plugin's own `CLAUDE.md` isn't loaded. If
  the bullet is reworded, it must still name both controls, a version and an ISO date. Plan:
  `docs/plans/archive/verify-plugin-rules-bundling.md`.
- **Loosening user-only skills (plugin doc "Install this plugin", as of 2026-11-25).** Facts to
  check any prose against (skills docs fetched 2026-11-25): `${CLAUDE_PLUGIN_ROOT}` is substituted
  *only in plugin skills*, so a project copy of `retro` (which runs
  `${CLAUDE_PLUGIN_ROOT}/scripts/config-audit.sh`) breaks; `scaffold` uses `${CLAUDE_SKILL_DIR}`
  and survives a folder copy. A project skill named `plan` replaces the built-in `/plan` in a
  local terminal session. `Skill(<name>)` deny rules in `permissions` restrict which skills
  Claude invokes, with no plugin exclusion in the docs (untested on plugin skills); see
  [[feedback-recurring-defects]] item 31 for the one-way-door check. A `/name` after plain
  text must be a separate word with no punctuation attached, or the call is blocked (sourced: the
  "Control who invokes a skill" section, below the deploy example: "If Claude tries when your
  message doesn't include `/deploy` as a separate word with no punctuation attached, Claude Code
  blocks the call"; the "Where you write the skill's name" table states only the condition).
- **Claims beyond the recorded mechanics** (how an unversioned plugin updates, say) need their own
  dated source.

See [[feedback-hook-script-review]], [[feedback-recurring-defects]].
