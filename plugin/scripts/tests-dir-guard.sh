#!/bin/bash
# PreToolUse "Write|Edit" guard for the test-writer subagent (Appendix B).
# Plugin agents ignore frontmatter hooks, so this runs for every Write or Edit and acts
# only when the call comes from test-writer; agent_type is "<plugin>:test-writer" then.
INPUT=$(cat)
AGENT=$(printf '%s\n' "$INPUT" | jq -r '.agent_type // empty')
case "$AGENT" in
  *:test-writer|test-writer) ;;
  *) exit 0 ;;
esac

FILE=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0
REL=${FILE#"${CLAUDE_PROJECT_DIR:-$PWD}"/}

# Outside the project, or climbing out of a directory with "..": never a test file.
case "$REL" in
  /*|../*|*/../*|*/..|..) REL="" ;;
esac
# Allowed when any directory in the path is a test directory.
case "/$REL" in
  */test/*|*/tests/*|*/__tests__/*|*/spec/*|*/specs/*) exit 0 ;;
esac
echo "Blocked: test-writer edits only files under a test directory (test/, tests/, __tests__/, spec/, specs/). Report the production change needed instead." >&2
exit 2
