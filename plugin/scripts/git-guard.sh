#!/bin/bash
# Add as a second PreToolUse "Bash" hook, or fold into bash-guard.sh.
# A tripwire for slips, not a sandbox: command-segments.awk, kept beside this script, reads the
# command as text, so a command hidden in a variable, an alias or sh -c '...' gets past it.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
SEGMENTS=$(printf '%s\n' "$COMMAND" | awk -f "$(dirname "$0")/command-segments.awk")

# Blanket adds sweep up other sessions' files and ignored artefacts: -A, --all, -u, --update,
# or the whole tree as a path (., .., ./, :/, *). A path such as docs/x.md passes.
if echo "$SEGMENTS" | grep -E '^git add ' |
  grep -E ' (-[a-zA-Z]*[Au][a-zA-Z]*|--all|--update|\.\.?/?|:/|\*)( |$)' > /dev/null; then
  echo "Blocked: stage explicit paths (git add <path>), not the whole tree." >&2
  exit 2
fi
# git commit -a (or --all) stages every tracked change, so it sweeps the same way. In a
# cluster, a letter after one that takes a value (-m, -F, -C, -c, -t, -S, -u) is that value.
if echo "$SEGMENTS" | grep -E '^git commit ' |
  grep -E ' (-[^-mFCctSu ]*a[a-zA-Z]*|--all)( |$)' > /dev/null; then
  echo "Blocked: git commit -a or --all stages every tracked change. Stage explicit paths (git add <path>) and commit without it." >&2
  exit 2
fi

# A commit stays local until it is pushed, so let commits through and ask before a push.
# Each takes allow, ask or block; anything else counts as block.
COMMITS=allow
PUSHES=ask

# Plugin settings: a project overrides either default by setting MINNEL_GIT_GUARD_COMMITS or
# MINNEL_GIT_GUARD_PUSHES in its .claude/settings.json "env".
COMMITS=${MINNEL_GIT_GUARD_COMMITS:-$COMMITS}
PUSHES=${MINNEL_GIT_GUARD_PUSHES:-$PUSHES}
# End of plugin settings.

strictest() { # the stricter of two decisions: block over ask over allow
  case "$1" in allow|ask|block) ;; *) echo block; return ;; esac
  case "$2" in allow|ask|block) ;; *) echo block; return ;; esac
  case "$1 $2" in *block*) echo block ;; *ask*) echo ask ;; *) echo allow ;; esac
}
DECISION=allow
echo "$SEGMENTS" | grep -E '^git commit( |$)' > /dev/null && DECISION=$(strictest "$DECISION" "$COMMITS")
echo "$SEGMENTS" | grep -E '^git push( |$)' > /dev/null && DECISION=$(strictest "$DECISION" "$PUSHES")

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
