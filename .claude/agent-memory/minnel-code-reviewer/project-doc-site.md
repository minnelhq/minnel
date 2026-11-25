---
name: project-doc-site
description: The doc site (MkDocs-format config, built with Zensical since ADR 0003); recurring review checks it introduces
metadata:
  type: project
---

The repo renders `docs/` as a site (ADR 0002 chose MkDocs Material; ADR 0003 moved the build to
Zensical, which reads `mkdocs.yml` as-is). The source has no build; the site is an optional
publish build. Since ADR 0005 (0.5.0) `docs.yml` deploys to GitHub Pages on each push to `main`
(or a manual run on `main`), never from a pull request.

**Why:** the site is the methodology's public front door, and its build and CI add checks prose
review doesn't cover.

**Zensical facts (verified 2026-11-22 against 0.1.3; re-check on any upgrade):**
- Link and anchor validation default to on; `build --strict` exits 1 on a broken page link or
  anchor, cached rebuilds included. `serve --strict` is accepted but unsupported.
- `theme.variant` defaults to `modern`, which uses `lucide/*` icons.
- Licence MIT, `Requires-Python >=3.11`.

**How to apply:**
- The "source has no build; the site is optional" wording must stay coherent across the
  `CLAUDE.md` intro, the DoD preamble, the site-build and repo-setup text, and ADRs 0002/0003.
  Watch for a bare "no build" or a stale "deployed by a manual run". That text sat in README
  "Reading it as a site" and "Dogfooding" until the 2026-11-25 README rewrite moved it to
  `CONTRIBUTING.md` (check which file holds it now).
- **README and `docs/index.md` (2026-11-25 rewrite).** A first draft mirrored the README section
  for section, against ADR 0002's "kept lean so the two do not drift"; the user chose to trim
  `index.md` to the shared opening, quick start and a Read-more list. Those shared paragraphs
  have no check pairing them: compare them on any edit to either, and sweep the install line's
  version (2.1.292) across README, index, `plugin/README.md` and `docs/plugin.md`. A summary of
  that pin must stay conditional ("On 2.1.292 or later, install…"), since older versions install
  in two steps.
- Published means `docs/` minus `exclude_docs` in `mkdocs.yml` (a fixed list, not keyed off
  git-ignore). Build with the main checkout's `.venv/bin/zensical build --strict --clean`.
- The DoD's `paths:` must cover any new site, build or CI config file, and agree with the
  site-build item's trigger list.
- `docs/worked-example.md` keeps a dangling link (`does/not/exist.md`) inside a code fence on
  purpose; outside a fence `--strict` fails.
- Files outside `docs_dir` (the template, the changelog, `.claude/` files) are linked by absolute
  GitHub blob URLs at `minnelhq/minnel`. The repo moved there from
  `tcrossland/claude-code-methodology` on 2026-11-25; ADRs, archived plans and released changelog
  entries keep the old path as records. Flag a live doc that still names it. Checked 2026-11-25:
  the old Pages host 404s, old web and git URLs 301 to the new repo (existing marketplace entries
  with the old source still refresh), and the `github-pages` environment kept its `main` branch
  policy. Released plugin copies (0.7.0 and earlier) link the old Pages host until a release.
- **CI.** Deploy and upload are gated on `refs/heads/main` and push or dispatch; the `pages`
  concurrency group is workflow-level for those runs, as in GitHub's Pages starter. Keep it that
  way: a job-level group orders deploys by build-finish time. Least-privilege `permissions`,
  write scopes only on the deploy job, actions pinned to SHAs with version comments (verify a SHA
  against its tag with `gh api`), Pages action majors matched, `persist-credentials: false` on
  checkouts (checkout v6+ keeps the token in a file under `$RUNNER_TEMP`, not `.git/config`).
- **Mermaid.** A vendored `docs/assets/vendor/mermaid-<ver>/mermaid.min.js` loads from a raw
  `<script>` at the end of each page with a `mermaid` fence. Zensical's bundle falls back to
  `unpkg.com/mermaid@12` when `mermaid` is undefined, so a page missing the tag, or with a wrong
  `src`, still renders and passes `--strict`. The `docs.yml` step resolves each `src` against the
  page dir and checks the major against the bundle's fallback; on a Zensical upgrade, re-check that
  major. Licence: mermaid is MIT, but the file bundles DOMPurify (Apache-2.0 OR MPL-2.0), lodash and
  cytoscape (MIT), noted in a comment at its end (read it with `python3 -I`; the line is too long
  for grep). On an upgrade, `cmp` the vendored files against the registry tarball after checking
  its integrity hash. `.gitattributes` marks the vendor dir `binary`.
- **Chart direction.** §8's lifecycle chart went `LR` → `TB` in b5729ea (2026-11-24): an
  `LR` chart rendered in a short frame with labels illegible at 375 px, and the `TB` one got a
  frame sized to the chart (the coordinator's observation on a scratch branch; I didn't see it).
  So a `TB` chart here isn't a finding; the user's global rendered-docs rule now asks for
  top-to-bottom past four nodes too (read 2026-11-25). Ask for a render check at desktop and 375 px.
- **Redirects (2026-11-25, `docs/plugin.md` rename).** `mkdocs.yml` has a `redirects` plugin with
  `packaging-as-a-plugin.md: plugin.md`. Zensical 0.1.3 implements it natively (`zensical/config.py`
  normalises `redirect_maps`); no new dependency, and the page keeps the `#anchor`. Its first
  reason (v0.6.0 installs' `plugin/README.md` links it) lapsed with the 2026-11-25 move: those
  links name the old Pages host, which 404s. Keeping or dropping it is the user's call. No
  MkDocs-compatibility notes: the user's Zensical rule in `~/.claude/rules/` says so, and
  keeps ADRs and released changelog entries that name MkDocs as records (added 2026-11-25).
- The site is not "own assets only": the theme links Google Fonts, and the bundle loads a
  `resize-observer-polyfill` from unpkg on old browsers.
