# ADR 0006 — Self-host the site's Mermaid

**Status:** accepted   **Date:** 2026-11-24

## Context
The methodology draws its §2 loop, §6 hook path and §8 lifecycle as Mermaid diagrams. GitHub draws
them itself. On the site, Zensical's bundle draws them with mermaid.js, and when the page hasn't
already loaded one it fetches `mermaid@12` from unpkg. That is a third-party script with no exact
version and no integrity hash, served on a site that otherwise loads only its own assets.

The minified mermaid.js is 5.5 MB, 1.58 MB gzipped. Only the methodology page has diagrams.

## Decision
Vendor one pinned mermaid.js under `docs/assets/vendor/mermaid-<version>/`, with its `LICENSE`, and
load it from a `<script>` tag at the end of each page that draws a diagram. Today that is
`methodology.md` alone.

- The tag sits before Zensical's bundle in the built page, so the bundle finds a global `mermaid`
  and fetches nothing. GitHub strips the tag from its own rendering.
- The first copy is mermaid 12.3.0 (MIT, read from the package's own `LICENSE`), checked against
  the sha512 the npm registry publishes for it.
- The docs workflow fails when a built page draws a diagram without the vendored script, or when
  the vendored major differs from the one Zensical's bundle would fetch.
- `.gitattributes` marks the vendored directory binary, and `.ignore` keeps searches out of it, so
  a grep never prints the 300,000-character lines.

## Consequences
- No page fetches a script from a CDN, and only the page that draws diagrams loads the 1.58 MB.
- A new page with a diagram needs the same `<script>` line. CI catches a page that lacks it.
- Upgrading means a new versioned directory: download the package tarball from the npm registry,
  check it against the registry's `dist.integrity`, read its `LICENSE`, and update the `src` in
  each page that loads it. Each upgrade adds about 5.5 MB to the history.
- A Zensical release that moves its fallback to another Mermaid major fails CI until the vendored
  copy follows.

## Alternatives considered
- **Keep Zensical's unpkg load** — rejected: a third-party script on every diagram page, at
  whichever 12.x unpkg serves that day.
- **Load the vendored copy through `extra_javascript`** — rejected: every page would download the
  1.58 MB, though one page draws diagrams.
