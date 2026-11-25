#!/bin/bash
# Reads the tool call as JSON on stdin; exit 2 blocks and returns stderr to Claude.
# A tripwire for slips, not a sandbox: command-segments.awk, kept beside this script, reads the
# command as text, so a command hidden in a variable, an alias or sh -c '...' gets past it.

# What a match does: allow, ask or block; anything else counts as block. allow turns the guard off.
BASH_GUARD=block

# Plugin settings: a project overrides the default by setting MINNEL_BASH_GUARD in its
# .claude/settings.json "env".
BASH_GUARD=${MINNEL_BASH_GUARD:-$BASH_GUARD}
# End of plugin settings.

INPUT=$(cat)
[ "$BASH_GUARD" = allow ] && exit 0
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command // empty')
SEG_AWK="$(dirname "$0")/command-segments.awk"
[ -r "$SEG_AWK" ] || { echo "Blocked: $SEG_AWK is missing; keep it beside this guard." >&2; exit 2; }
SEGMENTS=$(printf '%s\n' "$COMMAND" | awk -f "$SEG_AWK")

block() {
  if [ "$BASH_GUARD" = ask ]; then
    # Exit 0 with this JSON shows the user a permission prompt instead of blocking the call.
    jq -cn --arg why "Bash guard: $1. Check the command before you approve." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $why}}' &&
      exit 0
  fi
  echo "Blocked: $1. Run it yourself if you really mean it." >&2
  exit 2
}

# rm with a recursive and a force flag, in any order or cluster.
printf '%s\n' "$SEGMENTS" | grep -E '^rm ' | grep -E ' (-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)( |$)' |
  grep -E ' (-[a-zA-Z]*f[a-zA-Z]*|--force)( |$)' > /dev/null && block "a recursive, forced rm"
# A force push (--force, -f or a +refspec). --force-with-lease passes to the git guard's prompt.
printf '%s\n' "$SEGMENTS" | grep -E '^git push ' |
  grep -E ' (--force|-[a-zA-Z]*f[a-zA-Z]*|\+[^ ]+)( |$)' > /dev/null && block "a force push"
# SQL sits inside an argument, so this one matches anywhere in the command, quotes included.
printf '%s\n' "$COMMAND" | grep -iE '\bDROP TABLE\b' > /dev/null && block "DROP TABLE"
exit 0
