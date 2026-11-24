---
name: triage
description: Triage the backlog — check each item still applies, reorder Next, group it by release and show the roadmap.
disable-model-invocation: true
---

Triage the backlog in `docs/backlog.md`. Draft only: do not edit files until I approve.

1. Read the backlog, the active plan, the changelog the conventions in context name
   (`CHANGELOG.md` by default) and the commits since the last release tag. The
   active-plan pointer names the plan; it lives where `CLAUDE.md` says, by default in
   the backlog's Now section. If the conventions, in the project's `CLAUDE.md` or
   `.claude/rules/` or in `~/.claude/`, name a private-notes path (the template labels
   it `Private/working notes:`), and `git check-ignore` confirms git ignores a file
   there, read any backlog kept in it too.
2. Check that each item still applies. Flag any that has shipped (its outcome is in the
   changelog or the commits), is out of date (what it names has moved on), or duplicates
   another; an item the active plan covers is in progress, not stale. Propose deleting a
   shipped item, with an Unreleased line for its user-facing outcome if the changelog
   lacks one; rewriting or parking a stale one; and merging duplicates.
3. Re-tag what has changed (type, value, effort, why now). Propose an order for Next:
   value against effort, with an item that others depend on ahead of them.
4. Propose a grouping for Next under a heading for each release (`### <version>`): the
   items due in the next release or the one after, earliest release first, and the rest
   under `### Unscheduled`. Keep step 3's order within each group, and leave Later
   ungrouped. Suggest each release's version from its items' types: under Conventional
   Commits a `feat` makes a minor release, a `fix` a patch and a breaking change a major.
   A `debt` or `chore` item needs no release of its own unless an installer would notice
   it. Flag a heading that names a version already released. If items carry an inline
   `target: <version>` tag instead, propose moving each under its version's heading and
   dropping the tag.
5. Show the roadmap: the active plan under Now, or none; then Next as grouped, each
   version with its suggested bump and the item types behind it; then Later as one
   undated group. Once the draft is applied, the tracked backlog shows the same grouping
   without the private items.
6. Include private items in the roadmap in this chat only, and group them under the same
   headings where they are kept. The tracked backlog groups tracked items only, and
   names a private blocker in general terms.
7. Present the draft as changes to the backlog, one line of reason each, followed by the
   roadmap. I choose what to apply.
