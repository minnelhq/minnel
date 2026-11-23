---
name: project-doc-site
description: The doc site (MkDocs-format config, built with Zensical since ADR 0003); recurring review checks it introduces
metadata:
  type: project
---

The repo renders `docs/` as a site (ADR 0002 chose MkDocs Material; ADR 0003 moved the build to
Zensical, which reads `mkdocs.yml` as-is). The site work added the repo's first CI
(`.github/workflows/docs.yml`) and reconciled the old `no build, no runtime` invariant to "the
*source* has no build; the site is an optional publish build".

**Why:** the methodology needs an owned public front-door. ADR 0002 deferred deploy until the
brand was locked (the "Christen" backlog item); as of 2026-11-22 the site is live on GitHub Pages
under the current repo name anyway, deployed by manual `workflow_dispatch`. ADR 0005 (branch
`claude/auto-deploy-docs`, reviewed 2026-11-24) switches to deploy on every push to `main`.
Re-verify which is current before relying on it.

**Zensical facts verified 2026-11-22 against 0.1.3 in `.venv` (re-check on any upgrade):**
- Link and anchor validation default to on (`zensical/config.py`, the "Initialize defaults for
  validation" block); a `validation:` block in `mkdocs.yml` is optional.
- `theme.variant` defaults to `modern`; `lucide/*` icons are what the modern variant uses.
- `build --strict` exits 1 on a broken page link or anchor, and a cached (non-`--clean`) rebuild
  still fails, so the cache does not mask warnings. `serve --strict` is accepted but unsupported.
- Licence MIT (dist-info `LICENSE.md`), `Requires-Python >=3.11`.

**How to apply (recurring checks when these areas change):**
- The reconciled wording must stay coherent across: `CLAUDE.md` intro, the DoD preamble
  (`.claude/rules/definition-of-done.md`), README "Reading it as a site" and "Dogfooding", and
  ADRs 0002/0003. If one is edited, check the others did not drift back to a bare "no build" or
  to "not yet deployed".
- The site build is the gate for any published doc / `mkdocs.yml` / `requirements.txt` change.
  Published = under `docs/` minus the `exclude_docs` list in `mkdocs.yml` (`backlog.md`,
  `plans/`, `design/`, and the gitignored notes folder). `exclude_docs` is a fixed
  list, not keyed off git-ignore, so a new gitignored docs path the hook skips would still need
  adding here. Run `.venv/bin/zensical build --strict --clean`.
- The DoD is path-scoped (`paths:` frontmatter), so it only loads when a matching file is touched.
  If a new site/build config file or CI file is introduced, check the DoD's `paths:` still covers
  it, and that the site-build item's own trigger list agrees with what `paths:` loads it for.
- `docs/worked-example.md` deliberately contains a dangling link (`does/not/exist.md`) inside a
  code fence to demonstrate the consistency hook. It must stay inside a fence; if it leaves one,
  `--strict` fails.
- The site can't reach files outside `docs_dir`, so `worked-example.md` repoints a few refs to
  absolute GitHub blob URLs at `tcrossland/claude-code-methodology`. Known rebrand debt, now on a
  live site: flag if the repo is renamed. The 0.4.0 retitle to "Minnel: …" (Stage 4, 2026-11-23)
  changed `site_name` and the H1s only; repo name, URL and blob URLs stay, and renaming the repo is
  out of that plan's scope. So a claim that the retitle "settled" ADR 0002's brand/domain hold
  over-reaches: the name is decided, the domain is not.
- CI gate (as reviewed 2026-11-24, ADR 0005 branch): upload step and deploy job gated
  `github.event_name != 'pull_request'`, `pages` concurrency group moved to the deploy job. Two
  traps I flagged: (a) with no ref check, a manual run from a non-main branch reaches the deploy
  job, enters `pages`, can replace a pending main deploy, then fails on the `github-pages`
  environment's branch policy (custom policy, `main` only, verified via `gh api` that day);
  (b) a job-level group orders deploys by build-finish time, not push time, so two close pushes
  can publish the older one last. GitHub's Pages starter (`actions/starter-workflows`
  `pages/static.yml`) keeps the group at workflow level. Re-check whichever shape merged.
  Before ADR 0005: deploy job and upload step both gated to `workflow_dispatch`; top-level `permissions: contents: read`, write perms (`pages: write`, `id-token: write`) only on
  the deploy job. Pages action pair must stay matched majors. Actions are pinned to commit SHAs
  with version comments; verify a SHA matches its tag via `gh api`.
- Both workflows' checkout steps set `persist-credentials: false` (2026-11-23); no step needs git
  auth (deploy uses OIDC, no checkout). Re-check if a step that pushes or fetches is added. Note
  that checkout v6+ keeps the token "in a separate file under `$RUNNER_TEMP` instead of
  directly in `.git/config`" (read from the pinned v7.0.0 README) — prose saying otherwise is off.
- (Pre-ADR 0005.) Because deploy is manual, the live site lags `main` until someone dispatches. Prose that says
  only "a change of look" waits for a manual run understates this.
- The workflow header comment (and a backlog item copying it, 2026-11-23) says auto-deploy means
  "drop the `workflow_dispatch` gates". The workflow also runs on `pull_request`, so removing the
  `if:` gates outright would upload and attempt a Pages deploy from every PR. A push-deploy gate
  needs to exclude PRs (e.g. `github.event_name != 'pull_request'`). Re-check when the workflow
  triggers change. Carriers of the manual-deploy claim to sweep if it flips: README site section,
  ADR 0003, the workflow comments, and the CI item in `.claude/rules/definition-of-done.md` (until 2026-11-23 the example sat in this repo's own reviewer, now retired).
