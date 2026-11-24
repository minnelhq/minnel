# ADR 0003 — Build the doc site with Zensical

**Status:** accepted; superseded in part by ADR 0005 (deploy)   **Date:** 2026-11-22   **Amended:** 2026-11-25 (the redirect)

## Context
ADR 0002 chose MkDocs Material to render `docs/` as a site. Its build now prints a notice that
Material for MkDocs reaches end of life on 2027-05-05. ADR 0002 already named the way out:
Zensical, the Material team's successor, which reads an existing `mkdocs.yml` as it stands.

Zensical is MIT-licensed (read from its own `LICENSE.md`) and needs Python 3.11 or later. It is
still in beta: version 0.1.3, with several releases a month. Its `zensical build --strict` exits
with code 1 on any warning, and a link to a missing page or anchor raises one by default, so CI
can keep failing on a broken link.

ADR 0002 also deferred deployment until the public name was locked. The site has since been
published to GitHub Pages at <https://tcrossland.github.io/claude-code-methodology/> by a manual
run of the `docs` workflow, so that part of 0002 no longer describes the repo.

## Decision
Build the site with **Zensical** in place of MkDocs Material.

- Keep `mkdocs.yml` as the configuration. Zensical reads it; converting to `zensical.toml` can
  wait until a setting needs it.
- Pin `zensical~=0.1.3` in `requirements.txt`, so a breaking minor release does not reach CI
  unannounced.
- Use the `modern` theme variant, with a header toggle that cycles through system, light and
  dark (Lucide icons).
- Drop the MkDocs `validation:` block. Zensical's defaults already warn on a missing page or
  anchor, and CI runs `zensical build --strict --clean`, so either one fails the build.
- Deployment stays a manual `workflow_dispatch` run. A push to `main` builds and validates but
  does not publish, so the published site changes only when the maintainer chooses, and lags
  `main` until then.

## Consequences
- The site no longer depends on a theme with an end-of-life date.
- Beta churn is the cost: a flag or setting may change between releases. The pin contains it,
  and each upgrade is a deliberate edit with a local strict build first.
- Reverting is small: `requirements.txt` back to `mkdocs-material` and the CI build command back
  to `mkdocs build --strict`. The theme variant and Lucide icons would need reverting too, and
  MkDocs needs the `mkdocs-redirects` plugin for the redirect in `mkdocs.yml`, which Zensical
  handles itself.
- The Definition of Done and the `code-reviewer` agent name the Zensical build command;
  `CLAUDE.md` names Zensical as the site tool.
- The links in `worked-example.md` that point at GitHub blob URLs are now on a live site, so
  renaming the repository breaks them for readers until they are repointed.
- `zensical serve` does not yet accept `--strict`, so a local preview only warns about a broken
  link; the strict build is the gate.

## Alternatives considered
- **Stay on MkDocs Material until its end of life** — rejected: it defers a move that has to
  happen anyway, and the site's tooling would carry a fixed expiry date until then.
- **Convert to `zensical.toml` now** — rejected for now: a larger diff for no gain today, and
  keeping `mkdocs.yml` keeps a revert small (see Consequences).
