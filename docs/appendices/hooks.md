# Methodology appendices — hooks

Drop-in project hooks for the methodology. Companion to `../methodology.md`; the full index is in this directory's `README.md`.

## Appendix C — project hooks

The plugin ships the two guards as `plugin/scripts/bash-guard.sh` and `plugin/scripts/git-guard.sh`, wired in `plugin/hooks/hooks.json`. Its `git-guard.sh` adds per-project settings for how it treats commits and pushes.

`.claude/settings.json` (excerpt)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/bash-guard.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/format-and-test.sh" }
        ]
      }
    ]
  }
}
```

`.claude/hooks/bash-guard.sh` — block a destructive command class

```bash
#!/bin/bash
# Reads the tool call as JSON on stdin; exit 2 blocks and returns stderr to Claude.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -iE '\brm -rf\b|\bgit push --force\b|\bDROP TABLE\b' > /dev/null; then
  echo "Blocked: destructive command. Run it yourself if you really mean it." >&2
  exit 2
fi
exit 0
```

`.claude/hooks/git-guard.sh` — block blanket staging, and ask before a push (§9)

```bash
#!/bin/bash
# Add as a second PreToolUse "Bash" hook, or fold into bash-guard.sh.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Blanket adds sweep up other sessions' files and ignored artefacts.
# Match -A, --all or a bare . (or ./) as its own argument, so a path like docs/x.md passes.
if echo "$COMMAND" | grep -iE '\bgit add\b.*[[:space:]](-A|--all|\./?)([[:space:]]|$)' > /dev/null; then
  echo "Blocked: stage explicit paths (git add <path>), not the whole tree." >&2
  exit 2
fi
# git commit -a (or --all) stages every tracked change, so it sweeps the same way.
if echo "$COMMAND" | grep -iE '\bgit commit\b.*[[:space:]](-a[a-zA-Z]*|--all)([[:space:]]|$)' > /dev/null; then
  echo "Blocked: git commit -a or --all stages every tracked change. Stage explicit paths (git add <path>) and commit without it; if -a or --all appears later on the line, split the command." >&2
  exit 2
fi

# A commit stays local until it is pushed, so let commits through and ask before a push.
# Each takes allow, ask or block; anything else counts as block.
COMMITS=allow
PUSHES=ask

strictest() { # the stricter of two decisions: block over ask over allow
  case "$1" in allow|ask|block) ;; *) echo block; return ;; esac
  case "$2" in allow|ask|block) ;; *) echo block; return ;; esac
  case "$1 $2" in *block*) echo block ;; *ask*) echo ask ;; *) echo allow ;; esac
}
DECISION=allow
echo "$COMMAND" | grep -iE '\bgit commit\b' > /dev/null && DECISION=$(strictest "$DECISION" "$COMMITS")
echo "$COMMAND" | grep -iE '\bgit push\b' > /dev/null && DECISION=$(strictest "$DECISION" "$PUSHES")

case "$DECISION" in
  block)
    echo "Blocked: this project reviews git commits and pushes itself. Summarise the diff instead." >&2
    exit 2 ;;
  ask)
    # Exit 0 with this JSON shows the user a permission prompt instead of blocking the call.
    jq -cn --arg why "Git guard: check the branch, the remote and the commits before you approve." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $why}}' \
      || { echo "Blocked: the git guard could not ask you about this command." >&2; exit 2; } ;;
esac
exit 0
```

