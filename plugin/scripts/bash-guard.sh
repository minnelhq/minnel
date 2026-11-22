#!/bin/bash
# Reads the tool call as JSON on stdin; exit 2 blocks and returns stderr to Claude.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -iE '\brm -rf\b|\bgit push --force\b|\bDROP TABLE\b' > /dev/null; then
  echo "Blocked: destructive command. Run it yourself if you really mean it." >&2
  exit 2
fi
exit 0
