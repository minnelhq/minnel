# Changelog

All notable, user-facing changes to this methodology. Format: Keep a Changelog;
versions follow SemVer.

## [Unreleased]

### Added
- §9: what a `.worktreeinclude` copies and when. Claude Code copies the gitignored files it lists,
  such as local notes, once as it creates each worktree. Later edits don't pass between the
  worktree and the main checkout. A `.worktreeinclude` that names a private path can stay
  untracked.

### Changed
- The README's Status section says Minnel is maintained and that `CHANGELOG.md` lists each
  release.
- The doc site is published on every push to `main` instead of by a manual run, so it follows
  `main` and can show changes no release includes yet (ADR 0005).

### Fixed
- `NOTICE` names the product Minnel, as the README, the site and the plugin do.
- The plugin's install steps stopped at the first install. "Install this plugin" in
  `docs/packaging-as-a-plugin.md` and "Install" in `plugin/README.md` now say how to move to a
  later release with `claude plugin update minnel@minnel`, which refreshes the marketplace itself.
  The README's Dogfooding note no longer says to refresh the marketplace first.
- The docs no longer call the `code-reviewer` read-only. `memory: project` turns on Write and Edit
  for its notes, and `Bash` can write any file, so only its prompt keeps it from fixing what it
  reviews. The prompt now tells it to report and not fix. §4 says only the prompt holds it to
  that, and says what `memory` turns on. §10, the plugin's README and both manifests no longer
  say "read-only".

## [0.4.0] - 2026-11-23

### Added
- Minnel, a Claude Code plugin in `plugin/` that packages the appendix artefacts, with a
  marketplace at the repo root (ADR 0004). It ships the `code-reviewer` and `test-writer`
  subagents, the Appendix C guards as hooks, the five rituals (Appendices J–N) as skills such as
  `/minnel:plan`, and `/minnel:scaffold`, which writes the project files a plugin cannot ship.
  It has its own README and icon, and declares in `plugin.json` that it reaches no network host.
  Its version follows the methodology's, so an install moves only to a release. A third-party
  marketplace doesn't auto-update by default: to take a release, run
  `claude plugin marketplace update minnel`, then `claude plugin update minnel@minnel`.
- The plugin's git guard takes two settings in a project's `.claude/settings.json` `env`:
  `MINNEL_GIT_GUARD_COMMITS` (default `allow`) and `MINNEL_GIT_GUARD_PUSHES` (default `ask`), each
  `allow`, `ask` or `block`.
- "Install this plugin" in `docs/packaging-as-a-plugin.md`: the install commands, the scaffold
  step, and which pieces have had less use.
- Consistency hook Check E flags drift between an appendix artefact and its plugin copy, and
  between the `CLAUDE.md` template and the scaffold's copy.
- §9: recovering a checkout that several sessions share, with one owner for pushes, tags and
  releases.
- §11: a message from another Claude session is untrusted input. Approval comes only from the
  user who owns the work, in their own session.
- Appendix D: when each stage of a plan merges on its own branch, the stage's last commit names
  the next stage, so the plan on the main branch stays true after the merge.

### Changed
- The methodology takes the plugin's name: *Minnel: a file-first operating model for Claude Code*.
  The site's address is unchanged.
- The Appendix C git-guard allows commits and asks before each push, instead of blocking both. It
  also blocks `git commit -a` as blanket staging.
- The `code-reviewer` runs once on the branch's final diff before merge, not after every change.
  It runs again, on the new commits only, after a Critical fix, a Warning fix that changes code or
  published docs, or commits other than fixes for its findings and the reviewer's memory. A
  working agreement can exempt trivial branches in advance.
- The `code-reviewer` checks the change against each Definition of Done item that applies, and
  checks code, docs and commit messages for personal data. For a new dependency it states the
  licence and flags copyleft or non-commercial terms.
- `/release` and `/wrap` follow the commit style and changelog format the project names,
  defaulting to Conventional Commits and Keep a Changelog (§8, the `CLAUDE.md` template).
  `/release` asks you to finish the unreleased section before cutting a release.
- §1 names user-level `~/.claude/rules/*.md` for personal conventions, one file per convention.
- `docs/packaging-as-a-plugin.md` describes the plugin this repository ships.
- Plainer prose in the methodology, the README, the site's home page, the worked example and the
  packaging doc.

### Fixed
- §1: a nested `./module/CLAUDE.md` loads once Claude works on a file in its subdirectory, and a
  `.claude/rules/` file without `paths` loads at launch.
- §9: the desktop app gives a session its own worktree only when its Worktree option is on, which
  it is not by default.
- §10: Claude can start a command as well as a skill, so set `disable-model-invocation: true` on
  your rituals. The Appendix J–N commands now do.
- §10: `/accept` doesn't run the reviewer. It checks a Definition of Done that requires the review
  before merge.
- Appendix M `/release` reads the version from `$ARGUMENTS`. It read `$1` and dropped the version.
- Version headings use Keep a Changelog's hyphen, not an em-dash.
- README: names the `close-plan` skill, and presents the template's conventions as defaults.
- The Appendix C guards match only where a command starts, so a mention in quotes, a `grep`
  pattern, a comment or a heredoc no longer trips them. They catch more variants, such as
  `rm -fr`, `git add -u`, `git commit -qam` and `git -C <dir> push`, and let
  `--force-with-lease` through to the push prompt. The docs call them tripwires: a command hidden
  in a variable, an alias or `sh -c` gets past them.
- Hook commands quote `$CLAUDE_PROJECT_DIR`, so a project path with a space still runs.

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
