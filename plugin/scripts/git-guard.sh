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

# Plugin opt-out: a project that lets Claude commit sets METHODOLOGY_GIT_GUARD_COMMITS=0
# in its .claude/settings.json "env". The blanket-staging block above still applies.
[ "${METHODOLOGY_GIT_GUARD_COMMITS:-1}" = 0 ] && exit 0

# Commits and pushes go through you, not the agent.
if echo "$COMMAND" | grep -iE '\bgit (commit|push)\b' > /dev/null; then
  echo "Blocked: commits and pushes are reviewed by the human. Summarise the diff instead." >&2
  exit 2
fi
exit 0
