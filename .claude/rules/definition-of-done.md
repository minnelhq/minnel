---
paths:
  - "*.md"
  - "**/*.md"
  - ".claude/**"
  - "/mkdocs.yml"
  - "/requirements.txt"
  - ".github/**"
  - "plugin/**"
  - ".claude-plugin/**"
---

# Definition of Done

<!-- Adapted from methodology Appendix E for this docs repo: the Markdown has no build/test/lint
     step, so the bar is consistency and review rather than a green suite, and the plugin adds its
     own item below. Deliberate divergence. -->

A change is not done until ALL of these hold. Do not report a task complete until you have
checked each one and can say which evidence confirms it. The Markdown source has no build, test
or lint step; the bar is consistency and review, not a green suite. The plugin has its own item.
(The doc site is an optional publish build — see the site-build item below and ADRs 0002 and
0003.)

- [ ] **British English throughout** — spelling, ISO `YYYY-MM-DD` dates, `£`/`€` before figures.
- [ ] **Internal consistency** — every `§N` cross-reference and appendix letter (A–Q) touched
      by the change resolves to the right target; nothing dangling or mis-lettered. When a
      number or letter moved, every reference to it moved too.
- [ ] **No contradiction or duplication** — new guidance does not conflict with, or silently
      restate, what another doc already says.
- [ ] **Links and paths resolve** — intra-repo references point at files that exist.
- [ ] **Nothing personal in tracked files** — no secrets, keys, personal endpoints or
      machine-specific paths, and no pointer to the gitignored local-notes folder.
- [ ] **Descriptive claims are true** — CHANGELOG lines, README statements, doc-to-doc pointers,
      and prose file paths match the *current* contents they describe, not merely resolve as links.
- [ ] **CLAUDE.md stays lean** — if it was touched, it has not accreted rules that belong in
      `docs/` or `.claude/`.
- [ ] **CHANGELOG.md `[Unreleased]` updated** if the change is user-facing. For a methodology
      whose docs are the product, that is most guidance changes — internal churn aside.
      (Pre-release: corrections to not-yet-released content stay under *Added*; no separate
      *Changed* entry until there is a released baseline.)
- [ ] **Doc-site build (when touched)** — if the change edits `mkdocs.yml`, `requirements.txt`,
      `.github/workflows/docs.yml`, or a published doc (anything under `docs/` except the working
      artefacts `exclude_docs` lists in `mkdocs.yml`, such as `backlog.md`, `plans/` and `design/`),
      `zensical build --strict` completes cleanly. (The one deliberately-broken link in
      `docs/worked-example.md` lives inside a code fence, so the build does not parse it.) See
      ADRs 0002 and 0003.
- [ ] **Plugin (when touched)** — if the change edits `plugin/` or `.claude-plugin/`,
      `plugin/scripts/tests/all-awks.sh` passes (it runs `guards.sh` and `commit-msg.sh` under
      each installed awk; CI covers mawk and gawk, so install them to check before a push, and
      report a `skip` line as unchecked, not as a pass), and `claude plugin validate plugin` and
      `claude plugin validate .` pass. Warnings are allowed only where `main` gives them too.
      Each behaviour a guard, hook or plugin script (not the tests) gains, and each one a commit
      message claims, has a `guards.sh` or `commit-msg.sh` case that fails when the behaviour is
      removed. Leave `plugin.json`'s `version` alone outside a release commit (see the Release
      item).
- [ ] **Release (when cutting one)** — `plugin/.claude-plugin/plugin.json`'s `version` equals the
      new CHANGELOG version (ADR 0004). Installs stay on the cached copy until it changes, so a
      release that leaves it alone ships no plugin change. Raise it in the release commit, not
      before: once the marketplace is refreshed, `claude plugin update` would move installs to
      unreleased work. After the merge, an annotated tag `vX.Y.Z` sits on the merge commit and a
      GitHub Release published from it carries the version's changelog section as its notes.
      Report this part as *pending* until the merge.
- [ ] **Hook and guard scripts safe (when touched)** — no unquoted expansions and no injection via
      tool input; paths inside the plugin use `${CLAUDE_PLUGIN_ROOT}` and hook commands
      `$CLAUDE_PROJECT_DIR`, each quoted (`"$CLAUDE_PROJECT_DIR"/...`) so a path with a space
      still runs.
- [ ] **CI workflows (when touched)** — `.github/workflows/*.yml` grant least-privilege
      `permissions`, and any publish or deploy step is gated as the docs say (the Pages deploy
      runs on a push to `main` or a manual run on `main`, never on a pull request; ADR 0005).
- [ ] **`minnel:code-reviewer` subagent run on the final branch diff before merge**, with no
      Critical findings outstanding: once per branch, not per change, and not for a trivial branch
      (the working agreement in `CLAUDE.md` says what counts). Until the branch is ready to merge,
      report this item as *pending*, not FAIL.
- [ ] **Active plan in `docs/plans/` advanced** if one is live (stage, ticked steps, deviations).

If any item cannot be met, stop and say so rather than working around it.
