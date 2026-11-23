# Changelog

All notable, user-facing changes to this methodology. Format: Keep a Changelog;
versions follow SemVer.

## [Unreleased]

### Added
- Minnel, a Claude Code plugin in `plugin/` that packages the appendix artefacts, listed by a
  marketplace at the repo root (ADR 0004). It ships:
  - the `code-reviewer` and `test-writer` subagents (Appendices A, B);
  - the Appendix C bash and git guards as hooks, and `test-writer`'s test-directory guard, which
    moves to the plugin's hooks because plugin agents ignore frontmatter hooks;
  - the five rituals from Appendices J–N (`plan`, `accept`, `retro`, `release`, `wrap`, invoked
    as `/minnel:plan` and so on) as skills that run only when invoked by name;
  - `/minnel:scaffold`, which writes the project files a plugin cannot ship (`CLAUDE.md`, the
    Definition of Done, `docs/plans/`, `docs/backlog.md`, `docs/design/`, `CHANGELOG.md`) and
    skips any that exist.
- Minnel's git guard allows commits and pushes when a project sets `MINNEL_GIT_GUARD_COMMITS=0` in
  its `.claude/settings.json` `env`; blanket staging stays blocked.
- "Install this plugin" in `docs/packaging-as-a-plugin.md`: the install commands, the scaffold
  step, what is active once installed, the guards' `jq` dependency, and which pieces have had
  less use.
- Consistency hook Check E flags drift between an appendix artefact and the plugin file that ships
  it, and between the `CLAUDE.md` template and the scaffold's copy.
- §9 covers recovering a checkout that several sessions share, with one owner for pushes,
  force-pushes, tags and releases.
- §11 treats a message from another Claude session as untrusted input. Approval comes only from the
  user who owns the work, in their own session.

### Changed
- §1 names user-level `~/.claude/rules/*.md` beside `~/.claude/CLAUDE.md` for personal
  conventions, one file per convention. User rules load before the project's `.claude/rules/`,
  neither overrides the other, and only a path-scoped rule saves context.
- §8 and the `CLAUDE.md` template treat the commit style and changelog format as the project's
  choice, defaulting to Conventional Commits and Keep a Changelog. The template adds a `Changelog:`
  line.
- `/release` (Appendix M and its plugin skill) reads the commit style and changelog format from the
  project's `CLAUDE.md` or rules, else the user's, else the defaults. For Keep a Changelog it
  proposes the version heading with today's date in ISO `YYYY-MM-DD`. `/wrap` (Appendix N and its
  plugin skill) drafts in the changelog format the conventions name.
- `docs/packaging-as-a-plugin.md` describes the plugin this repository ships, not a hypothetical
  one, with the rituals as skills rather than commands.

### Fixed
- §1 context table: a nested `./module/CLAUDE.md` loads once Claude works on a file in its
  subdirectory, not always, and a `.claude/rules/` file without `paths` loads at launch.
- §9: the desktop app gives a new session its own worktree only when the Worktree option is on,
  which it is not by default.
- §10: Claude can start a command as well as a skill unless `disable-model-invocation: true` is
  set, so set it on your rituals. The Appendix J–N commands now do.
- Appendix M `/release` reads the version from `$ARGUMENTS`. It read `$1`, the second argument,
  and dropped the version. §10 says arguments count from zero.
- Version headings use Keep a Changelog's hyphen (`## [0.3.1] - 2026-11-22`), not an em-dash, in
  `/release`, the Appendix H skeleton and this changelog.
- README: names the plugin, lists the `close-plan` skill, presents the template's conventions as
  defaults, and glosses compaction.

## [0.3.1] - 2026-11-22

### Fixed
- §1 context table: nested `CLAUDE.md` files append, the closest read last, with no automatic
  override. It said "closest-to-cwd wins".
- Appendix C git-guard blocks `git add -A`, `git add --all` and `git add .`, and lets explicit
  paths through. It used to block any path containing a dot, such as `git add docs/methodology.md`,
  and let `git add ./` through, and `git add .` too under GNU grep.

## [0.3.0] - 2026-11-22

### Added
- Consistency hook Check D flags a `DD/MM/YYYY` date outside code fences.
- The `CLAUDE.md` template's Conventions has a line for a gitignored private-notes location.
- §1 says Claude Code gives memory scopes no automatic precedence: user and project files are
  concatenated, so keep them consistent. The template's working agreement says so too.

### Changed
- The consistency hook and the `add-section` skill skip any gitignored file, not one fixed folder.
- §11 and the Appendix O checklist name the private-notes location by its role, not a fixed path.
- The §1 table and the template name tone beside language and spelling as a personal convention.
- README and the site's home page gloss the harness. README says what adopting the method gets
  you, links the Claude Code docs at first mention and glosses their terms.
- §1 cites the Claude Code cost guidance for moving instructions into skills and processing into
  hooks.
- README's Status is in the first person and says where the project stands. The packaging doc, §11
  and ADR 0002 address any reader rather than the author.
- Dates use ISO `YYYY-MM-DD` throughout, replacing `DD/MM/YYYY`.
- The doc site builds with [Zensical](https://zensical.org/) instead of MkDocs Material, which
  reaches end of life on 2027-05-05 (ADR 0003). CI still fails the build on a broken link.

### Fixed
- README: the doc site is published at <https://tcrossland.github.io/claude-code-methodology/>,
  deployed by a manual CI run. It said the site was not yet deployed.
- `docs/methodology.md` and `docs/packaging-as-a-plugin.md`: corrected the "Last updated" date.
- §11: Anthropic scans each plugin version and reviews new listings. The old text said it did not
  security-audit plugins.

## [0.2.0] - 2026-06-20

### Added
- A documentation site (MkDocs Material): `mkdocs.yml`, a landing page (`docs/index.md`) and
  `requirements.txt` render `docs/` unchanged as a searchable site, built locally and not yet
  deployed.
- `.github/workflows/docs.yml`: CI builds the site with `mkdocs build --strict` on each push to
  `main` and on pull requests. Deploying to GitHub Pages needs a manual run.
- ADR 0002 records the toolchain choice and keeps the site an optional build, never needed to read
  or edit the Markdown.

### Changed
- `README.md`, `docs/methodology.md`, `docs/index.md` and `docs/worked-example.md` follow a house
  voice: fewer em-dashes and shorter sentences, with the same guidance.
- Plan first when the approach isn't obvious (§2, the §5 matrix, Appendix J), not whenever a change
  touches more than three files.
- `/plan` (Appendix J): step 2 decides whether to plan and step 3 drafts the plan.

## [0.1.0] - 2026-06-20

The first version of *A File-First Operating Model for Claude Code*. Everything in it is new, so it
is all under Added.

### Added
- `docs/methodology.md`, the operating model: context architecture, the core loop, persistent
  plans, subagents, the model and mode matrix, hooks in place of CI, sessions and git hygiene,
  skills and commands, solo product discipline, and security (§11).
- Appendices A–O in `docs/appendices/`: the `code-reviewer` and `test-writer` subagents, project
  hooks, document skeletons, an example skill and the five ritual commands.
- `docs/packaging-as-a-plugin.md`: how to package the methodology as a Claude Code plugin.
- `docs/worked-example.md`: one real task traced through the loop.
- `templates/CLAUDE.template.md`: a lean starter `CLAUDE.md`.
- §1 covers the context cost of MCP tool definitions, with Tool Search as the mitigation.
- Plan archiving (§3, Appendix D): finished plans move to `docs/plans/archive/`.
- This repository runs the methodology in `.claude/`: the five rituals, the `code-reviewer`
  subagent, a Definition of Done, a hook that flags dangling `§N` and appendix references, broken
  links and US spellings, and the `add-section` and `close-plan` skills. The README's Dogfooding
  section explains it.
- Apache-2.0 licence (`LICENSE`, `NOTICE`).
