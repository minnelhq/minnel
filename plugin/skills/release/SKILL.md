---
name: release
description: Draft unreleased changelog entries from the completed plan and commits; once a release is merged, tag and publish it.
argument-hint: "[version]"
disable-model-invocation: true
---

Prepare a changelog update — draft only, do not edit files until I approve.

If the version given ($ARGUMENTS) already has its heading in the changelog on the
remote's main branch (after `git fetch`) but no tag for that version on the remote
(`git ls-remote --tags origin`), the release is cut but not closed: skip the steps below
and propose the closing steps at the end instead.

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
6. If a version was given, read the backlog (`docs/backlog.md`) and list any item still
   under that version's heading in Next (or tagged `target: <version>`, the older
   format) at the top of the draft: work meant for this release is still open. If the
   conventions in context name a private-notes path (the template labels it
   `Private/working notes:`) and `git check-ignore` confirms git ignores a file there,
   check any backlog kept in it the same way, and name its items in this chat only. For
   each item, propose deleting its line if the commits show the item has shipped;
   otherwise propose finishing it before the cut, or moving it under a later release's
   heading or Unscheduled (for a tagged item, changing or dropping its tag). Propose
   removing the version's heading once it is empty. If no version was given, suggest one
   from the changes.
   Under Conventional Commits a `feat` makes a minor release, a `fix` a patch, and
   a breaking change a major.

Exclude internal-only changes (refactors, test scaffolding, doc tweaks) unless an
installer would notice. I will curate before anything is committed.

When cutting a release, fold every intended change into the unreleased section and
review it first, then cut once. Don't cut the release commit and amend later additions
into it.

To close a release once its commit is on the main branch, make an annotated tag on the
commit that put it there (for a pull request, the merge or squash commit it made) and
push it: `git tag -a v<version> -m v<version> <commit>`, then
`git push origin v<version>`. If the tag already exists locally, push it rather than
make it again. Use the tag format the conventions name, if they name one. Where the
host publishes releases, publish one from the pushed tag with the version's changelog
section as its notes; on GitHub,
`gh release create v<version> --verify-tag --notes-file <file holding that section>`.
Pushing the tag and publishing the release change shared state, so run both only with
my go-ahead.
