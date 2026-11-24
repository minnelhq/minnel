#!/bin/sh
# Read-only input for /retro's pruning step (Appendix L): lists each configuration and memory
# file with its line count, then every file path those files name that no longer exists.
#
# Files read: the project's CLAUDE.md, .claude/CLAUDE.md, CLAUDE.local.md, .claude/rules/,
# .claude/agent-memory/ and .claude/agent-memory-local/, and the user's ~/.claude/CLAUDE.md,
# ~/.claude/rules/ and ~/.claude/agent-memory/. Symlinked rules and directories are followed.
# A path is a code span, a Markdown link target or an @import holding a "/" that starts with
# "/", "~/" or ".", ends with "/", or has a dot in its last part; one bare name (plans/) is not. Globs, placeholders
# (<name>), variables, URLs, git remotes (git@host:...), slash commands and anything with a
# space are skipped. A project
# file's relative path counts as present if it resolves against the project root or the file's
# own directory, or ends some file in the project (add-section/SKILL.md), or, for a directory
# ending in "/", appears in a project file's path. A user file applies to
# every project, so only its absolute and ~/ paths are checked. This is a heuristic: read each
# hit before acting on it, since a note may name an old path on purpose.
#
# Run it by hand or from /retro; it is not a hook, so it costs no context until asked for.
# POSIX sh, writes nothing, and always exits 0: a missing directory or tool means less output.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
USER_DIR="${HOME:-}/.claude"

list_files() { # scope dir-or-file ... — prints "scope<TAB>path" for each Markdown file
  scope=$1; shift
  for p in "$@"; do
    if [ -f "$p" ]; then printf '%s\t%s\n' "$scope" "$p"
    elif [ -d "$p" ]; then
      find -L "$p" -type f -name '*.md' 2>/dev/null | sort | sed "s|^|$scope	|"
    fi
  done
}

files=$( {
  list_files project "$ROOT/CLAUDE.md" "$ROOT/.claude/CLAUDE.md" "$ROOT/CLAUDE.local.md" \
    "$ROOT/.claude/rules" "$ROOT/.claude/agent-memory" "$ROOT/.claude/agent-memory-local"
  [ -n "${HOME:-}" ] && list_files user "$USER_DIR/CLAUDE.md" "$USER_DIR/rules" "$USER_DIR/agent-memory"
} )

show() { # absolute path -> path as printed: relative to the project, or ~/ for the user's
  case "$1" in
    "$ROOT"/*)   printf '%s' "${1#"$ROOT"/}" ;;
    "${HOME:-/nonexistent}"/*) printf '~/%s' "${1#"$HOME"/}" ;;
    *)           printf '%s' "$1" ;;
  esac
}

# Candidate paths in one file, as "line<TAB>path".
candidates() {
  awk -v q="'" '
    function keep(t, line) {
      sub(/#.*/, "", t)                       # drop a #fragment
      sub(/:[0-9]+(-[0-9]+)?$/, "", t)        # drop a :line or :line-line suffix
      sub(/[.,;:)]+$/, "", t)                 # drop trailing punctuation
      if (t == "" || t !~ /\//) return
      if (t ~ /[ *?<>{}$|=]/ || index(t, "[") || index(t, "]") || index(t, q) || index(t, "\"") || index(t, "@")) return
      if (t ~ /\.\.\./ || t ~ /^[A-Za-z][A-Za-z0-9+.-]*:/) return
      if (t ~ /^\.git\// || t ~ /^[A-Za-z0-9-]+\.[A-Za-z.]+\//) return  # git internals, a bare domain
      u = t; sub(/\/$/, "", u)
      if (u !~ /^[.~]/ && u !~ /.\//) return     # one bare name (/release, plans/) is not a path
      n = split(u, part, "/")
      if (t ~ /^(\/|~\/|\.)/ || t ~ /\/$/ || part[n] ~ /\./) print line "\t" t
    }
    {
      s = $0
      while (match(s, /`[^`]+`/)) { keep(substr(s, RSTART + 1, RLENGTH - 2), FNR); s = substr(s, RSTART + RLENGTH) }
      s = $0
      while (match(s, /\]\([^) ]+[) ]/)) { keep(substr(s, RSTART + 2, RLENGTH - 3), FNR); s = substr(s, RSTART + RLENGTH) }
      s = $0
      while (match(s, /(^|[ \t])@[^ \t]+/)) {
        t = substr(s, RSTART, RLENGTH); sub(/^[ \t]*@/, "", t); keep(t, FNR); s = substr(s, RSTART + RLENGTH)
      }
    }' "$1" 2>/dev/null
}

echo "Line counts:"
printf '%s\n' "$files" | while IFS='	' read -r scope f; do
  [ -n "$f" ] || continue
  printf '%6s  %s\n' "$(wc -l < "$f" | tr -d ' ')" "$(show "$f")"
done

exists() { # scope file path — true when the path resolves
  case "$3" in
    \~/*) [ -n "${HOME:-}" ] && [ -e "$HOME/${3#??}" ] ;;
    /*)    [ -e "$3" ] ;;
    *)     [ "$1" = user ] || [ -e "$ROOT/$3" ] || [ -e "$(dirname "$2")/$3" ] || in_repo "$3" ;;
  esac
}
in_repo() { # path — a directory appears in a project file's path; a file ends one
  case "$1" in
    */) printf '%s\n' "$repo_files" | grep -qF -- "/$1" ;;
    *)  printf '%s\n' "$repo_files" | t="/$1" awk 'BEGIN { t = ENVIRON["t"] }
          length($0) >= length(t) && substr($0, length($0) - length(t) + 1) == t { f = 1; exit }
          END { exit !f }' ;;
  esac
}
find_missing() {
  printf '%s\n' "$files" | while IFS='	' read -r scope f; do
    [ -n "$f" ] || continue
    candidates "$f" | while IFS='	' read -r ln p; do
      exists "$scope" "$f" "$p" || printf '  %s:%s: %s\n' "$(show "$f")" "$ln" "$p"
    done
  done
}

# The project's files, for the tail match; empty outside git, which skips that check.
repo_files=$(git -C "$ROOT" ls-files --cached --others --exclude-standard 2>/dev/null | sed 's|^|/|')

echo "Paths that no longer exist:"
missing=$(find_missing | awk '!seen[$0]++')
if [ -n "$missing" ]; then printf '%s\n' "$missing"; else echo "  none"; fi
exit 0
