#!/bin/bash
# Reads the tool call as JSON on stdin; exit 2 blocks and returns stderr to Claude.
# A tripwire for slips, not a sandbox: command-segments.awk, kept beside this script, reads the
# command as text, so a command hidden in a variable, an alias or sh -c '...' gets past it.
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command // empty')
SEG_AWK="$(dirname "$0")/command-segments.awk"
[ -r "$SEG_AWK" ] || { echo "Blocked: $SEG_AWK is missing; keep it beside this guard." >&2; exit 2; }
SEGMENTS=$(printf '%s\n' "$COMMAND" | awk -f "$SEG_AWK")

block() {
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
