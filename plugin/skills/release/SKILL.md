---
name: release
description: Draft CHANGELOG Unreleased entries from the completed plan and commits.
argument-hint: "[version]"
disable-model-invocation: true
---

Prepare a changelog update — draft only, do not edit files until I approve.

1. Read the active plan and the commits since the last release tag.
2. Summarise only the user-facing changes, one concise line each.
3. Sort them into Keep a Changelog categories: Added, Changed, Deprecated,
   Removed, Fixed, Security. Omit empty categories.
4. Propose these under `## [Unreleased]` in CHANGELOG.md.
5. If a version was given ($ARGUMENTS), also propose renaming Unreleased to
   `## [$ARGUMENTS] — <today's date>`.

Exclude internal-only changes (refactors, test scaffolding, doc tweaks) unless an
installer would notice. I will curate before anything is committed.
