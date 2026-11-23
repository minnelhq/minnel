---
name: release
description: Draft unreleased changelog entries from the completed plan and commits.
argument-hint: "[version]"
disable-model-invocation: true
---

Prepare a changelog update — draft only, do not edit files until I approve.

1. Read the active plan and the commits since the last release tag. Find the commit
   style and changelog format in the conventions in context: the project's `CLAUDE.md`
   or `.claude/rules/`, else `~/.claude/CLAUDE.md` or `~/.claude/rules/` (the template
   labels them `Commit style:` and `Changelog:`). Where none names one, use its default:
   Conventional Commits for commits, Keep a Changelog for the changelog.
2. Summarise only the user-facing changes, one concise line each.
3. Sort them into the changelog format's categories. For Keep a Changelog: Added,
   Changed, Deprecated, Removed, Fixed, Security. Omit empty categories. With
   Conventional Commits, a commit's type suggests its category (`feat` → Added,
   `fix` → Fixed).
4. Propose these under the unreleased section of the changelog (`## [Unreleased]`
   in Keep a Changelog).
5. If a version was given ($ARGUMENTS), also propose the format's version heading
   in place of the unreleased one. For Keep a Changelog:
   `## [$ARGUMENTS] - YYYY-MM-DD`, with today's date.

Exclude internal-only changes (refactors, test scaffolding, doc tweaks) unless an
installer would notice. I will curate before anything is committed.
