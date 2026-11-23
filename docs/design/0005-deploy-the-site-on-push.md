# ADR 0005 — Deploy the doc site on every push to main

**Status:** accepted   **Date:** 2026-11-24

## Context
ADR 0003 kept deployment a manual `workflow_dispatch` run, so the published site would change
only when the maintainer chose. A push to `main` built and validated the site without publishing
it.

In practice each merge that changed a published doc needed its own manual run. Some went live
only when a later merge's run picked them up, so the site lagged `main` by an unknown amount.

ADR 0002 also held deploys back until the brand and domain were final, so that nothing would
auto-publish under a non-final name. ADR 0003 recorded the site as already live at its current
URL, so deploying on push adds no new exposure under an unfinished name. The Minnel retitle has
since settled the name; the URL still carries the repository's old one.

## Decision
Deploy the site to GitHub Pages on every push to `main`.

- The `docs` workflow's upload step and deploy job run only on `main`, for a push or a manual run.
  A pull request, or a run on another branch, still builds and validates the site and skips the
  deploy. The gate is an allow-list, so a trigger added later doesn't deploy unless it is named.
- The `github-pages` environment accepts deploys from `main` only: a second guard, kept in the
  repository's settings.
- Deploying runs share the workflow-level `pages` concurrency group, so pushes deploy one at a
  time and in the order they were made, and a newer pending run replaces an older one. Every
  other run gets a group of its own, so a pull request's build can't queue in `pages` and cancel
  a pending deploy.

## Consequences
- The published site tracks `main`, not releases. A change merged after a release shows on the
  site before it is in a tagged version, and the site doesn't say which version it describes.
- Merging becomes publishing. The strict build still fails on a broken link, so a merge that
  breaks the build fails before the upload, and the site stays as it was.
- The manual run on `main` stays, for redeploying without a new commit.
- The Definition of Done's CI item, the README's site section and the workflow's comments now
  describe the deploy on push.

## Alternatives considered
- **Keep manual deploys** — rejected: merges that changed a published doc were deployed by hand
  anyway, sometimes late.
- **Deploy only on a release tag** — rejected for now: the site would match the plugin's released
  version, but fixes to the docs would wait for a release, and releases are cut by hand. Revisit
  if the site needs to describe exactly one version.
