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
under the current repo name anyway, deployed by manual `workflow_dispatch`. Re-verify which is
current before relying on it.

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
  Published = under `docs/` except `backlog.md`, `plans/`, `design/`, `local/` (`exclude_docs` in
  mkdocs.yml). Run `.venv/bin/zensical build --strict --clean`.
- The DoD is path-scoped (`paths:` frontmatter), so it only loads when a matching file is touched.
  If a new site/build config file or CI file is introduced, check the DoD's `paths:` still covers
  it, and that the site-build item's own trigger list agrees with what `paths:` loads it for.
- `docs/worked-example.md` deliberately contains a dangling link (`does/not/exist.md`) inside a
  code fence to demonstrate the consistency hook. It must stay inside a fence; if it leaves one,
  `--strict` fails.
- The site can't reach files outside `docs_dir`, so `worked-example.md` repoints a few refs to
  absolute GitHub blob URLs at `tcrossland/claude-code-methodology`. Known rebrand debt, now on a
  live site: flag if the repo is renamed.
- CI: deploy job and the upload-pages-artifact step are both gated to `workflow_dispatch`;
  top-level `permissions: contents: read`, write perms (`pages: write`, `id-token: write`) only on
  the deploy job. Pages action pair must stay matched majors. Actions are pinned to commit SHAs
  with version comments; verify a SHA matches its tag via `gh api`.
- Because deploy is manual, the live site lags `main` until someone dispatches. Prose that says
  only "a change of look" waits for a manual run understates this.
