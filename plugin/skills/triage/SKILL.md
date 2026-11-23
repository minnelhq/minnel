---
name: triage
description: Triage the backlog: check each item still applies, reorder Next and propose release targets.
disable-model-invocation: true
---

Triage the backlog in `docs/backlog.md`. Draft only: do not edit files until I approve.

1. Read the backlog, the active plan, `CHANGELOG.md` and the commits since the last
   release tag.
2. Check that each item still applies. Flag any that has shipped (its outcome is in the
   changelog or the commits), is out of date (what it names has moved on), or duplicates
   another. Propose deleting a shipped item, rewriting or parking a stale one, and
   merging duplicates.
3. Re-tag what has changed (type, value, effort, why now). Propose an order for Next:
   value against effort, with an item that others depend on ahead of them.
4. Propose release targets for Next items (`target: <version>`), grouped into the next
   release and the one after. Suggest each release's version from its items' types:
   under Conventional Commits a `feat` makes a minor release and a `fix` a patch. Leave
   Later untargeted.
5. If the conventions in context name a private-notes path, and `git check-ignore`
   confirms git ignores it, read any backlog kept there too. Show the combined grouping
   only in this chat, or write it to those notes. The tracked backlog groups tracked
   items only, and names a private blocker in general terms.
6. Present the draft as changes to the backlog, one line of reason each. I choose what
   to apply.

Run it when Next no longer matches what you'd pick up, before planning a release, or
after one ships.
