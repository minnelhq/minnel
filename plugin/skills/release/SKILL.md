---
name: release
description: Draft CHANGELOG Unreleased entries from the completed plan and commits.
argument-hint: "[version]"
disable-model-invocation: true
---

Prepare a changelog update — draft only, do not edit files until I approve.

1. Read the active plan and the commits since the last release tag. Read the
   `Commit style:` and `Changelog:` lines in the project's `CLAUDE.md` Conventions;
   where one is missing, assume Conventional Commits or Keep a Changelog.
2. Summarise only the user-facing changes, one concise line each.
3. Sort them into the changelog format's categories. For Keep a Changelog: Added,
   Changed, Deprecated, Removed, Fixed, Security. Omit empty categories.
4. Propose these under the unreleased section of the changelog (`## [Unreleased]`
   in Keep a Changelog).
5. If a version was given ($ARGUMENTS), also propose the format's version heading
   in place of the unreleased one. For Keep a Changelog:
   `## [$ARGUMENTS] - YYYY-MM-DD`, with today's date.

Exclude internal-only changes (refactors, test scaffolding, doc tweaks) unless an
installer would notice. I will curate before anything is committed.
