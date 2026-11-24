---
name: triage
description: Triage the backlog — check each item still applies, reorder Next, propose release targets and show the roadmap they make.
disable-model-invocation: true
---

Triage the backlog in `docs/backlog.md`. Draft only: do not edit files until I approve.

1. Read the backlog, the active plan, the changelog the conventions in context name
   (`CHANGELOG.md` by default) and the commits since the last release tag. If those
   conventions, in the project's `CLAUDE.md` or `.claude/rules/` or in `~/.claude/`,
   name a private-notes path (the template labels it `Private/working notes:`), and
   `git check-ignore` confirms git ignores a file there, read any backlog kept in it too.
2. Check that each item still applies. Flag any that has shipped (its outcome is in the
   changelog or the commits), is out of date (what it names has moved on), or duplicates
   another; an item the active plan covers is in progress, not stale. Propose deleting a
   shipped item, with an Unreleased line for its user-facing outcome if the changelog
   lacks one; rewriting or parking a stale one; and merging duplicates.
3. Re-tag what has changed (type, value, effort, why now). Propose an order for Next:
   value against effort, with an item that others depend on ahead of them.
4. Propose release targets (`target: <version>`) for the Next items due in the next
   release or the one after; leave the rest, and Later, untargeted. Suggest each
   release's version from its items' types: under Conventional Commits a `feat` makes a
   minor release, a `fix` a patch and a breaking change a major. A `debt` or `chore`
   item needs no release of its own unless an installer would notice it. Flag a target
   that names a version already released. Also flag a Next item placed above one that
   targets an earlier release: either the order or a target is wrong.
5. Show the roadmap the proposed targets make: Next items grouped under each target
   version, earliest first, each version with its suggested bump and the item types
   behind it; then the Next items with no target; then Later as one undated group. The
   `target:` tags are the roadmap's only record, so show it in the chat and don't write
   it to a file.
6. Include private items in the roadmap in this chat only, and keep their targets with
   the private items. In the tracked backlog only tracked items carry targets, and it
   names a private blocker in general terms.
7. Present the draft as changes to the backlog, one line of reason each, followed by the
   roadmap. I choose what to apply.
