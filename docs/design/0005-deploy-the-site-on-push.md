# ADR 0005 — Deploy the doc site on every push to main

**Status:** accepted   **Date:** 2026-11-24

## Context
ADR 0003 kept deployment a manual `workflow_dispatch` run, so the published site would change
only when the maintainer chose. A push to `main` built and validated the site without publishing
it.

In practice each merge that changed a published doc needed its own manual run, and some went live
only when a later merge's run picked them up, so the site lagged `main` by an unknown amount. The other reason to hold deploys back, ADR 0002's wait for a
final name, has gone too: the Minnel retitle settled the name and kept the site's URL.

## Decision
Deploy the site to GitHub Pages on every push to `main`.

- The `docs` workflow's upload step and deploy job run on any event except `pull_request`: a push
  to `main` or a manual run. A pull request still builds and validates the site, and publishes
  nothing.
- The `github-pages` environment accepts deploys from `main` only, so a manual run on another
  branch builds but cannot publish.
- The `pages` concurrency group moves from the workflow to the deploy job. One deploy runs at a
  time, and a pull request's build can no longer queue in the group and cancel a pending deploy.

## Consequences
- The published site tracks `main`, not releases. A change merged after a release shows on the
  site before it is in a tagged version, and the site doesn't say which version it describes.
- Merging becomes publishing. The strict build still fails on a broken link, so a merge that
  breaks the build fails before the upload, and the site stays as it was.
- The manual run stays, for redeploying without a new commit.
- The Definition of Done's CI item, the README's site section and the workflow's comments now
  describe the deploy on push.

## Alternatives considered
- **Keep manual deploys** — rejected: merges that changed a published doc were deployed by hand
  anyway, sometimes late.
- **Deploy only on a release tag** — rejected for now: the site would match the plugin's released
  version, but fixes to the docs would wait for a release, and releases are cut by hand. Revisit
  if the site needs to describe exactly one version.
