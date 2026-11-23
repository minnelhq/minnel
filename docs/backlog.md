# Backlog

Ordered top to bottom; the top item is what gets picked up next. Tag each — type
(feat/fix/debt/chore), value (H/M/L), effort (H/M/L) — with a one-line *why now*. When an
item ships, move its user-facing outcome to `CHANGELOG.md [Unreleased]` and delete the line
here (§8). British English; dates ISO YYYY-MM-DD.

## Now (this plan)
- (none — no active plan)

## Next
- Appendix C guards: close the remaining bypasses or call them tripwires — fix · value M · effort L
  — why now: the bash-guard catches `rm -rf` but not `rm -fr` or `rm -r -f`, and the git-guard still
  passes `git add -Av`, `git add .;`, `:/`, `..`, `-u` and quoted dots; either broaden the patterns
  or say plainly they catch slips, not a determined command. The plugin ships the same scripts in
  `plugin/scripts/`; change both, and add the cases to `plugin/scripts/tests/guards.sh`.
- Quote `$CLAUDE_PROJECT_DIR` in hook commands — fix · value L · effort L — why now: the packaging
  doc now says to quote `${CLAUDE_PLUGIN_ROOT}` so a path with a space still runs, but Appendices B
  and C and this repo's `.claude/settings.json` leave `$CLAUDE_PROJECT_DIR` unquoted, and project
  paths with spaces are common. Check E doesn't compare B's hooks block, so it can change alone. Do
  it with the guards item, which edits the same Appendix C.
- Deploy the doc site on push to `main` — chore · value M · effort L — why now: each merge that
  changed the published docs needed a separate manual run of the `docs` workflow, and some went
  live only when a later merge's run picked them up. ADR 0003 kept deploys manual so the site
  changes only when the maintainer chooses; if every merge is deployed anyway, that reason no
  longer holds. Replace the `workflow_dispatch` gates in `.github/workflows/docs.yml` with one that
  excludes pull requests (`github.event_name != 'pull_request'`), since the workflow also runs on
  every PR. Record the reversal in a new ADR (or an amendment to 0003), and update what states the
  manual rule: the README's site section, the workflow's header and gate comments, and the example
  in `.claude/agents/code-reviewer.md`. ADR 0002 first held deploys back until the name was final,
  so settle the title item below first if it could change the site's name or URL.
- Decide whether the methodology's title takes the Minnel name — chore · value L · effort L — why
  now: the plugin is named Minnel, but the docs still title the methodology "A File-First Operating
  Model for Claude Code"; choose one before the first release that ships the plugin, which
  `[Unreleased]` now holds. That release also drops the README's "not yet in a tagged release".
- Dogfood Appendix C here, and extend Check E to this repo's commands — debt · value M · effort M
  — why now: this repo runs adapted copies of the J–N commands but not the git-guard, which is how
  its inverted regex went unnoticed. Check E now pins the plugin's copies to the appendices; extend
  it to compare `.claude/commands/*.md` too, allowing only marked project-specific deviations.
- Say how to enforce a stated convention, not only state it — feat · value M · effort M — why now:
  a `CLAUDE.md` line is advisory; describe a git `commit-msg` hook that validates the project's
  stated commit style (Conventional Commits by default). It catches human commits too and must not
  clash with the git-guard. Add a check that a `feat`/`fix` commit also touches `[Unreleased]`.
- Add Mermaid diagrams where the prose describes a flow — feat · value M · effort M — why now: the
  docs have none, and the §2 loop is one arrow line that hides its back-edges. Candidates: the §2
  loop, the §8 backlog → plan → changelog lifecycle, the §6/§11 hook path (`PreToolUse` guards,
  then the `PostToolUse` check) and, lower value, the packaging doc's appendix ↔ plugin pairs under
  Check E. Enable Zensical's `mermaid` custom fence in `mkdocs.yml`, set `layout: dagre` in each
  chart's frontmatter, draw left to right with short labels, and keep the prose beside each diagram
  so the Markdown stays readable on its own. Before shipping, check where Zensical loads Mermaid
  from (a CDN is a third-party script on the site) and view each chart on GitHub at desktop width
  and 375 px.

## Later / maybe
- Grow `/minnel:scaffold` into a bootstrap that asks for the adopter's conventions — feat · value H
  · effort H — why now: the scaffold copies templates and leaves the placeholders; a bootstrap would
  ask for language and spelling, date format, commit style, changelog format, private-notes path
  and the review gate, then fill the `CLAUDE.md` Conventions block, the Definition of Done,
  `CHANGELOG.md` and `docs/backlog.md`. It answers the configurable-preferences stance.
- Revisit the guards' default — feat · value M · effort L — why now: the plugin ships the guards on,
  and `MINNEL_GIT_GUARD_COMMITS=0` turns off the commit and push block per project (verified live
  2026-11-23). Blocking every commit is a personal stance; consider having the bootstrap offer the
  guards instead. Whether a project can disable a plugin's hooks wholesale is still unverified.

## Parked (with reason)
- (none)
