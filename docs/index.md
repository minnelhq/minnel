# Minnel

A file-first way of working with [Claude Code](https://code.claude.com/docs/en/overview), for
experienced solo developers and small teams.

Long Claude Code sessions lose things. Compaction, which summarises a long conversation to free
context, can drop the plan. A restart forgets what was decided, and a rule in `CLAUDE.md` holds
only while the model remembers it. Minnel answers with two habits. What must survive goes in
files: the plan, the decisions, the backlog and the changelog. What must hold is checked by hooks
(scripts Claude Code runs at set points in a session, such as before or after a tool call), which
don't depend on the model remembering, and by a review subagent (a separate AI assistant with its
own context and instructions) before merge.

## Quick start

The guards need `jq`. On Claude Code 2.1.292 or later, install the plugin:

```bash
claude plugin install minnel --marketplace minnelhq/minnel
```

Then, in a project, run `/minnel:scaffold`. It asks for the project's conventions, fills in the
project files with them, and reports what's left to fill, starting with the invariants.
[Install this plugin](plugin.md#install-this-plugin) covers older versions, install scopes and
updates.

## Read more

- [The methodology](methodology.md): what each piece is for, and why.
- [Worked example](worked-example.md): one real task traced end to end.
- [Appendices](appendices/README.md): the drop-in artefacts, for adopting Minnel without the
  plugin.
- [Minnel as a plugin](plugin.md): what the plugin installs, and how to update it or package your
  own.

This site follows `main`, so it can show changes no release includes yet. The source is on
[GitHub](https://github.com/minnelhq/minnel), with the
[changelog](https://github.com/minnelhq/minnel/blob/main/CHANGELOG.md), and is licensed
Apache-2.0.
