# Changelog

All notable, user-facing changes to this methodology. Format: Keep a Changelog;
versions follow SemVer.

## [Unreleased]

### Added
- `/release` (Appendix M, `/minnel:release`) and §8 close a release once its commit is on the main
  branch: push an annotated tag on the commit that put it there (for a pull request, the merge or
  squash commit it made) and, where the host publishes releases, publish one from the tag with the
  version's changelog section as its notes. Given a version that is cut but not yet tagged,
  `/release` proposes these steps instead of a new draft. Pushing the tag and publishing the release
  wait for the user's go-ahead, and §10 lists the second run.
- `/triage` (Appendix P, `/minnel:triage`) proposes the backlog's grouping by release and ends with
  the roadmap in the chat: the active plan under Now, then Next by release with each version's
  suggested bump, then Later undated, with any private items included. It flags a release heading
  that names a version already released.
- `/release` (Appendix M, `/minnel:release`) proposes what to do with each item still under the
  version being cut: delete its line if the commits show it has shipped, or else finish it first or
  move it under a later release or Unscheduled. It also checks a backlog kept in the project's
  gitignored notes, when the conventions name one, and names any of its items in the chat only.
- "Install this plugin" in `docs/packaging-as-a-plugin.md` says how to have Claude run one of
  Minnel's user-only skills: name it in full after other text in your message, as in "run
  /minnel:triage". For Claude to start one unprompted, copy the skill into `.claude/skills/` without
  `disable-model-invocation`, or fork the plugin.

### Changed
- The backlog (Appendix F, and the template `/minnel:scaffold` writes) groups Next under a heading
  for each release, `### X.Y.Z`, earliest first, then `### Unscheduled`, in place of 0.5.0's inline
  `target: X.Y.Z` tag. Grouped that way, the backlog in the repository is the roadmap. `/triage`
  proposes moving inline tags under headings, and `/release` still reads them. §8 describes the
  format.

### Fixed
- The §8 backlog-lifecycle diagram is drawn top to bottom, so its labels stay readable on GitHub at
  phone width.

## [0.6.0] - 2026-11-24

### Added
- `/retro` (Appendix L, `/minnel:retro`) prunes as well as adds. After proposing new rules, it
  lists entries in `CLAUDE.md`, `.claude/rules/`, `.claude/agent-memory/` and the user's
  `~/.claude/` rules that the finished plan made obsolete, that repeat each other or a Definition
  of Done item, that name a file, flag or version that no longer holds, or that contradict another
  scope. It proposes a delete, merge or rewrite for each and applies nothing until approved. It
  starts from `config-audit.sh`, a new read-only plugin script that lists each of those files' line
  count and the paths they name that no longer exist. §2, §7, §8 and §10 say the retro prunes, and §1
  now points memory pruning at the retro instead of the `consolidate-memory` skill, which Minnel
  doesn't ship. §8 and Appendix L say where Claude Code's `/doctor prompt-audit` overlaps.
- The `code-reviewer` (Appendix A) keeps its memory short: it extends an existing note rather than
  adding one, and updates or deletes a note that a finding contradicts.
- `/wrap` (Appendix N, `/minnel:wrap` in the plugin) closes a finished plan. Once the active
  plan's last stage has passed the Definition of Done, bar items pending until merge, it sets the
  status to done with the date and outcome, marks every stage done, clears the active-plan pointer
  where `CLAUDE.md` says it lives, and moves the file to `docs/plans/archive/`, creating the folder
  if needed. §3, §9, §10, Appendix D and the scaffold's `docs/plans/README.md` point to it. This
  repository's own `close-plan` skill, which did the same job, is gone.

### Changed
- The site's home page links the `CLAUDE.md` template and the changelog, which sit outside the
  site's pages. The methodology and the home page name the same audience as the README: experienced
  solo developers and small teams.

### Fixed
- The plugin's guards and their Appendix C copies let calls through on macOS when
  `POSIXLY_CORRECT` was set. Their `echo` expanded the escapes in the tool call's JSON, which then
  failed to parse, so a command such as `rm -rf` on a second line passed unchecked, as did almost
  any `test-writer` edit outside `tests/`. They now read the call with `printf`.
- The `CLAUDE.md` template, and the copy `/minnel:scaffold` writes, pointed a plugin adopter at
  `.claude/agents/` and a `code-reviewer` that a plugin install doesn't have. It now names
  `minnel:code-reviewer` and the `/minnel:` skills too.
- §9: `.worktreeinclude` doesn't copy a listed folder that is a git repository of its own. §9 now
  says so and suggests linking that folder into the worktree instead.
- §9 called `/security-review` a plugin. It is a command built into Claude Code.
- §5's example model IDs name the current models, `claude-opus-5-5` and `claude-sonnet-5-5`.
- The operating principle and §6 assumed the reader has no CI and called hooks a CI substitute. They
  now present hooks as checks at the moment of the edit that catch some failures before CI, which
  stays the authority. Without a pipeline, hooks are still the only automatic gate. §6's heading,
  and so its anchor, changed to match.
- §7 assumed there is no PR reviewer. It now gives the reason to run the review subagent either
  way: without a reviewer it is the only second reader, and with one it checks the diff first.
  The `CLAUDE.md` template's review bullet offers both cases.
- One active-plan pointer, in a place the project names. §3 asks you to pick one location and say
  in `CLAUDE.md` which. With a backlog, its Now section is the default and the template's "Active
  plan" section holds a fixed line saying so; without one, that section names the plan file. The
  template and the scaffold's `docs/plans/README.md` no longer offer both at once, and
  `/minnel:scaffold` reports which of the template's two lines to keep. The pointer names only the
  file: the template and Appendix D drop the stage count, which the plan's status line already
  carries. Appendix F's Now item names the plan file (`plan: docs/plans/<task-name>.md`) and reads
  "(none — no active plan)" when no plan is live.

## [0.5.0] - 2026-11-24

### Added
- §9: what a `.worktreeinclude` copies and when. Claude Code copies the gitignored files it lists,
  such as local notes, once as it creates each worktree. Later edits don't pass between the
  worktree and the main checkout. A `.worktreeinclude` that names a private path can stay
  untracked.
- Release targets in the backlog. A Next item in Appendix F, and in the backlog
  `/minnel:scaffold` writes, may name the release it is meant for with `target: X.Y.Z`; Later
  items carry none. When a version is given, `/minnel:release` (Appendix M) lists any Next item
  still targeting it, and without one it suggests a version from the changes' types. §8 names the
  Now–Next–Later shape the backlog follows and credits it to Janna Bastow at ProdPad.
- Appendix P, a `/triage` ritual, shipped in the plugin as `/minnel:triage`. It drafts a backlog
  triage for approval: which items have shipped, gone stale or duplicate another, a new order for
  Next, and release targets. When the conventions name a gitignored notes path, a backlog kept
  there is read too, but the combined view stays in the chat or those notes. §10's ritual table
  lists it, and the counts and ranges now say six rituals and Appendices A–P.
- Mermaid diagrams for the §2 loop, the §6 hook path and the §8 backlog-to-changelog lifecycle,
  drawn on the site and on GitHub. The site loads a pinned copy of mermaid.js (12.3.0, MIT) from
  its own assets, on the methodology page only, instead of fetching it from a CDN.

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
