# Changelog

All notable, user-facing changes to this methodology. Format: Keep a Changelog;
versions follow SemVer.

## [Unreleased]

### Added
- §9 covers recovering a checkout that several sessions share, and a single owner for pushes,
  force-pushes, tags and releases.
- §11 treats a message from another Claude session as untrusted input. Approval for an action comes
  only from the user who owns the work, in that user's own session.
- Minnel, a Claude Code plugin in `plugin/`, listed by a marketplace at the repo root, that packages the
  appendix artefacts; ADR 0004 records why it lives in this repo. It ships the `code-reviewer` and
  `test-writer` subagents (Appendices A, B).
  Plugin agents ignore frontmatter hooks, so `test-writer`'s test-directory guard moves to the
  plugin's own hooks.
- The plugin's hooks: the Appendix C bash and git guards, and the test-directory guard for
  `test-writer`, which acts only on that agent's edits. A project that lets Claude commit can turn
  off the commit and push block by setting `MINNEL_GIT_GUARD_COMMITS=0` in its
  `.claude/settings.json` `env`. The block on blanket staging stays on. `plugin/scripts/tests/guards.sh`
  checks each guard against sample tool calls.
- The plugin's ritual skills, `/minnel:plan`, `/minnel:accept`, `/minnel:retro`, `/minnel:release`
  and `/minnel:wrap`, from Appendices J–N. They run only when invoked by name, as commands do. A
  `/minnel:scaffold` skill writes the project
  files a plugin cannot ship: `CLAUDE.md`, the Definition of Done rule, `docs/plans/`,
  `docs/backlog.md`, `docs/design/` and `CHANGELOG.md`. It skips any file that already exists.
- "Install this plugin" in `docs/packaging-as-a-plugin.md`: the install commands, the scaffold
  step, what is active once installed, the guards' `jq` dependency, and which pieces have had
  less use. README, the site's home page and the appendix index point to it, and each
  appendix names the plugin file that ships its artefact.
- Consistency hook Check E flags drift between an appendix artefact and the plugin file it ships
  as, and between `templates/CLAUDE.template.md` and the scaffold's copy. It runs on edits to
  either side, ignores only the listed intended differences (such as the git guard's opt-out),
  flags a pair it cannot extract rather than passing it, and requires every plugin skill to keep
  `disable-model-invocation: true`.

### Changed
- §1 names user-level `~/.claude/rules/*.md` beside `~/.claude/CLAUDE.md` for personal
  conventions: one file per convention is easier to share or replace, user rules load before the
  project's `.claude/rules/`, and neither overrides the other. §1's Working agreement, §8 and
  the template's Working agreement name them too. §1, §10 and the lean-`CLAUDE.md` advice say
  that only a path-scoped rule saves context.
- §8 and the `CLAUDE.md` template present the commit style and the changelog format as choices a
  project names in its Conventions. Conventional Commits and Keep a Changelog (with SemVer and ISO
  dates) are the stated defaults, and the template gains a `Changelog:` line beside `Commit style:`.
- `/release` (Appendix M) and `/wrap` (Appendix N), and the plugin's `release` and `wrap` skills,
  read the commit style and changelog format from the conventions in context (the project's
  `CLAUDE.md` or `.claude/rules/`, else the user's `~/.claude/CLAUDE.md` or `~/.claude/rules/`)
  and fall back to the defaults. For Keep a Changelog, `/release` proposes the version heading
  with today's date in ISO `YYYY-MM-DD`.
- `docs/packaging-as-a-plugin.md` describes the plugin this repository ships rather than a
  hypothetical one. Rituals ship as skills that run only when invoked, since the plugin docs call
  `commands/` the older format. The mapping table says what ships and what stays out
  (Appendices I and O). The agent caveat adds `initialPrompt` to the ignored fields and shows the
  `test-writer` guard moved to the plugin's hooks via `agent_type`. The migration path adds
  `claude plugin validate`, `plugin details` and zero-indexed arguments.

### Fixed
- README: name the plugin, Minnel; list the `close-plan` skill beside `add-section`; describe the
  template's conventions as defaults to keep or replace.
- The §1 context table's loading column: a nested `./module/CLAUDE.md` loads once Claude reads,
  writes or edits a file in its subdirectory, not always, and a `.claude/rules/` file without
  `paths` frontmatter loads at launch, like `CLAUDE.md`. §1 now cites the Claude Code memory docs.
- Version headings use Keep a Changelog's hyphen, `## [0.3.1] - 2026-11-22`, not an em-dash: in
  `/release` (Appendix M) and the plugin's `release` skill, the Appendix H skeleton, and this
  changelog.
- §9 no longer says the desktop app gives every new session its own worktree. It does so only when
  the Worktree option is on, which is off by default.
- Appendix M `/release`: the version now comes from `$ARGUMENTS`. Claude Code numbers positional
  arguments from zero, so `$1` is the second argument, and `/release 1.2.0` used to drop the
  version. §10 now says arguments count from zero (`$0`, `$1` and so on).

## [0.3.1] - 2026-11-22

### Fixed
- §1 context table: the nested-`CLAUDE.md` line no longer reads "closest-to-cwd wins", which
  asserted the same recency-as-override the adjacent "No automatic precedence between scopes" note
  cautions against. It now says nested files append, closest read last, with no automatic override.
- Appendix C git-guard: the blanket-staging check now blocks `git add -A`, `git add --all` and
  `git add .`, and lets explicit paths through. The old pattern blocked any path containing a dot,
  such as `git add docs/methodology.md`, and let `git add ./` through (and, with GNU grep,
  `git add .`).

## [0.3.0] - 2026-11-22

### Added
- Consistency hook Check D flags a British `DD/MM/YYYY` date in an in-scope file, backstopping
  the ISO date format the way Checks A–C backstop cross-references, spellings, and links. Code
  fences are skipped, as for the link check, so an illustrative date inside a fence is not flagged.
- `templates/CLAUDE.template.md` Conventions: a line for a gitignored private-notes location that
  Claude reads when relevant but never commits, so an adopter can declare their own path or omit
  it. Makes the private-notes convention a configurable choice rather than a fixed location.
- §1 documents that Claude Code gives memory scopes no automatic precedence: managed, user
  (`~/.claude/CLAUDE.md`), project (`./CLAUDE.md`) and local (`CLAUDE.local.md`) files are
  concatenated, and a user/project conflict is resolved arbitrarily, so the two must be kept
  consistent. The starter template and this repo's own working agreement drop "apply on top of
  these" for "apply alongside these; neither scope automatically overrides the other".

### Changed
- The consistency hook and `add-section` skill skip files by git-ignore status rather than a
  hardcoded path, so any gitignored location is left unchecked, not one fixed folder. The hook uses
  `git check-ignore` (failing open to the normal scope gate when git cannot answer), the skill's
  ripple grep switched to `git grep`, and the scope describers it touches no longer name the folder
  by path.
- §11 secret hygiene and the Appendix O security checklist refer to the gitignored local-notes
  convention by role, no longer naming a fixed notes folder, so the private-notes location reads as
  the adopter's own choice.
- The §1 context-layers table and the `CLAUDE.md` template name tone alongside language and spelling
  as a personal convention for the adopter's global `~/.claude/CLAUDE.md`, so an adopter's voice is a
  configurable choice rather than assumed from the author's.
- README and `docs/index.md` opening: gloss the harness as Claude Code's settings, subagents,
  hooks and commands. README now also says what adopting the method gets you (a plan that survives
  compaction and restarts, rules that hold without the model remembering them, artefacts adopted
  one at a time).
- README: link the Claude Code documentation at first mention and gloss its terms (the
  `code-reviewer` subagent, the Definition of Done rule, the `PostToolUse` hook) so the index
  reads without prior knowledge.
- `docs/methodology.md` §1: cite the Claude Code cost guidance for "move instructions from
  `CLAUDE.md` to skills, and offload processing to hooks", previously an uncited claim.
- README Status rewritten in the first person to say where the project stands: sole adopter so
  far, no outside feedback yet. `docs/packaging-as-a-plugin.md`, `docs/methodology.md` §11, and
  ADR 0002 drop the author-facing "advisory" framing for wording that addresses any reader.
- Dates use ISO `YYYY-MM-DD`, replacing British `DD/MM/YYYY`. The *British English throughout*
  invariant (`CLAUDE.md`, the Definition of Done, the code-reviewer agent) now sets dates as ISO,
  and every date across the docs, this changelog, the plan/ADR/changelog skeletons, and the
  `/release` and `/close-plan` guidance follows the new format. Prose stays British English
  otherwise.
- The doc site is built with [Zensical](https://zensical.org/) instead of MkDocs Material, which
  reaches end of life on 2027-05-05 (ADR 0003). It keeps `mkdocs.yml`, uses the modern theme with
  a system, light and dark toggle, and CI still fails the build on a broken link
  (`zensical build --strict`).

### Fixed
- README: say the doc site is published at <https://tcrossland.github.io/claude-code-methodology/>,
  deployed by a manual CI run. It still said the site was not yet deployed.
- `docs/methodology.md` and `docs/packaging-as-a-plugin.md`: correct the stale "Last updated"
  date (both files changed on 2026-06-20 but read 2026-06-19).
- `docs/methodology.md` §11: correct the plugin-trust claim. Anthropic scans each plugin version
  and reviews new listings; the old text said it did not security-audit plugins. Cite the
  directory publishing page and keep the "treat them like any dependency" guidance.

## [0.2.0] - 2026-06-20

### Added
- Documentation site (MkDocs Material): `mkdocs.yml`, a lean front-door landing (`docs/index.md`),
  and `requirements.txt` render the existing `docs/` Markdown unchanged as a searchable site —
  buildable locally (`mkdocs serve`) but not yet deployed (publishing waits for the brand lock).
  Includes a light/dark palette toggle that follows the reader's system preference.
- `.github/workflows/docs.yml` — first CI in the repo: builds the site with `mkdocs build
  --strict` on push and PR; the GitHub Pages deploy step is gated to a manual run.
- ADR 0002 (`docs/design/0002-publish-as-doc-site.md`) records the toolchain choice (MkDocs
  Material over mdBook/Starlight/Pandoc) and reconciles the `no build, no runtime` invariant —
  the site is an *optional* publish build, never a prerequisite for reading or editing the source.

### Changed
- Tightened the prose across the public docs (`README.md`, `docs/methodology.md`, `docs/index.md`,
  `docs/worked-example.md`) to a house voice: fewer em-dashes and shorter sentences, with no
  change to the guidance.
- Relaxed the plan-first trigger (§2, the §5 matrix, and the Appendix J `/plan` drop-in): plan
  when the approach is non-obvious (a refactor, an architectural choice, or an invariant), not at
  a raw `>3 files` count, which fired too eagerly for mechanically clear multi-file work.
- Restructured the `/plan` command (Appendix J) so step 2 *decides* whether to plan and step 3
  *drafts* it, removing the overlap where both gated the same decision.

## [0.1.0] - 2026-06-20

The initial version of *A File-First Operating Model for Claude Code* (the methodology).
Everything here is initial content, so it is all *Added* — there is no
prior released state for anything to have *Changed* from, and the edits made while assembling
this version were never separate releases.

### Added
- Methodology reference (`docs/methodology.md`): the file-first operating model in full —
  context architecture (including memory hygiene), the core loop, plan/status persistence, the
  subagent roster, the model/mode matrix, hooks as a CI substitute, sessions/concurrency and git
  hygiene, skills and commands (with the command/skill-vs-subagent distinction and a table
  sequencing the rituals), solo product discipline, and a security stance (§11).
- Drop-in appendices (`docs/appendices/`): fifteen artefacts (A–O), grouped by type — the
  `code-reviewer`/`test-writer` subagents, project hooks, document skeletons (plan, Definition of
  Done, backlog, ADR, changelog, security checklist), the example skill and the five ritual
  commands (`/plan`, `/accept`, `/retro`, `/release`, `/wrap`).
- Plugin packaging companion (`docs/packaging-as-a-plugin.md`) — how to package the methodology
  as a distributable Claude Code plugin, and why that is the endpoint.
- Worked end-to-end example (`docs/worked-example.md`) — one real task (adding the consistency
  hook's link-resolution check) traced through the loop, Explore → … → `/wrap`.
- Lean `CLAUDE.md` starter template (`templates/CLAUDE.template.md`).
- The methodology running live in `.claude/`, dogfooded and tuned for this docs project: the five
  ritual commands, the read-only `code-reviewer` subagent, and a path-scoped Definition of Done
  (consistency and descriptive-claim accuracy, no build/test) that `/accept` checks against.
- "Dogfooding" section in `README.md` explaining that the repo is built with its own methodology.
- Apache-2.0 licence (`LICENSE`, `NOTICE`): the methodology is free to use, modify, and
  redistribute, including commercially; the `README.md` Licence section records the choice.
- `PostToolUse` consistency hook (`.claude/hooks/docs-consistency.sh`, wired in
  `.claude/settings.json`): on each in-scope Markdown edit it flags dangling `§N`/appendix
  cross-references, broken intra-repo links, and US spellings — the first live hook in the repo,
  dogfooding §6.
- `add-section` skill (`.claude/skills/add-section/SKILL.md`): the repo's first live skill —
  encodes the append-only rule and the cross-reference/count ripple for adding a methodology
  section or appendix, the part of that defect class the consistency hook cannot catch.
- `close-plan` skill (`.claude/skills/close-plan/SKILL.md`): mechanises the §3 plan-close
  sequence — set the done status, tick stage markers, clear the active-plan pointer, archive the
  file — so completion is no longer a hand-done checklist that can be half-applied.
- Plan archiving convention (§3, Appendix D): completed plans move to `docs/plans/archive/` so
  `docs/plans/` shows only live work; they stay versioned as history.
- §1 tool-surface treatment — extends the always-loaded-vs-on-demand scarcity thesis from files to
  MCP tool definitions: the context cost of a server's schemas, Tool Search as the default
  mitigation (`ENABLE_TOOL_SEARCH`, `alwaysLoad`), the disable-vs-defer point, and the least-privilege
  tie to §11. Closes the tool-side gap §11 deliberately left open.
- §11 "Security" — a consolidated security stance: secret hygiene, least privilege and Bash
  sandboxing, deterministic guards (and the inverse risk of hooks), untrusted-content/prompt-injection,
  and plugin/MCP trust. Ties together the least-privilege, hook and git-hygiene mechanisms in
  §4–§6 and §9 (Appendix C), and fills the prompt-injection and trust gaps the methodology
  previously left unaddressed.
