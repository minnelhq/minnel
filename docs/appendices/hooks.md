# Methodology appendices — hooks

Drop-in project hooks for the methodology. Companion to `../methodology.md`; the full index is in this directory's `README.md`.

## Appendix C — project hooks

The plugin ships the two guards as `plugin/scripts/bash-guard.sh` and `plugin/scripts/git-guard.sh`, wired in `plugin/hooks/hooks.json`. The copies below hard-code their defaults at the top of each script; the plugin's copies add per-project settings for each, which [Minnel as a plugin](../plugin.md) lists.

Both guards read the command through `command-segments.awk`, which splits a command line into the commands it runs. So they match `rm` or `git push` where a command starts, not where a quoted string, a `grep` pattern, a comment or a heredoc mentions it. Keep the three files in one directory: without `command-segments.awk` beside them, the guards block every `Bash` call and say why.

The guards are tripwires. They catch the slips an agent makes in passing: a blanket `git add`, a push nobody approved, a forced recursive delete. They read text, not a shell, so a determined command gets past them: one hidden in a variable or an alias, or run through `sh -c` or `eval`. The plugin's `plugin/scripts/tests/guards.sh` lists these accepted misses beside the cases the guards catch.

`.claude/settings.json` (excerpt)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/bash-guard.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format-and-test.sh" }
        ]
      }
    ]
  }
}
```

Quote `$CLAUDE_PROJECT_DIR` as above, so a project path with a space still runs.

`.claude/hooks/bash-guard.sh` — block a forced recursive delete, a force push and `DROP TABLE`

```bash
#!/bin/bash
# Reads the tool call as JSON on stdin; exit 2 blocks and returns stderr to Claude.
# A tripwire for slips, not a sandbox: command-segments.awk, kept beside this script, reads the
# command as text, so a command hidden in a variable, an alias or sh -c '...' gets past it.

# What a match does: allow, ask or block; anything else counts as block. allow turns the guard off.
BASH_GUARD=block

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
```

`.claude/hooks/git-guard.sh` — block blanket staging, and ask before a push (§9)

```bash
#!/bin/bash
# Add as a second PreToolUse "Bash" hook, or fold into bash-guard.sh.
# A tripwire for slips, not a sandbox: command-segments.awk, kept beside this script, reads the
# command as text, so a command hidden in a variable, an alias or sh -c '...' gets past it.

# Blanket staging sweeps up other sessions' files and ignored artefacts, so block it. A commit
# stays local until it is pushed, so let commits through and ask before a push.
# Each takes allow, ask or block; anything else counts as block.
STAGING=block
COMMITS=allow
PUSHES=ask

INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command // empty')
SEG_AWK="$(dirname "$0")/command-segments.awk"
[ -r "$SEG_AWK" ] || { echo "Blocked: $SEG_AWK is missing; keep it beside this guard." >&2; exit 2; }
SEGMENTS=$(printf '%s\n' "$COMMAND" | awk -f "$SEG_AWK")

strictest() { # the stricter of two decisions: block over ask over allow
  case "$1" in allow|ask|block) ;; *) echo block; return ;; esac
  case "$2" in allow|ask|block) ;; *) echo block; return ;; esac
  case "$1 $2" in *block*) echo block ;; *ask*) echo ask ;; *) echo allow ;; esac
}
DECISION=allow
staging() { # message: block now with it, or fold the staging setting into the decision
  if [ "$(strictest allow "$STAGING")" = block ]; then echo "Blocked: $1" >&2; exit 2; fi
  DECISION=$(strictest "$DECISION" "$STAGING")
}

# Blanket adds: -A, --all, -u, --update, or the whole tree as a path (., .., ./, :/, *).
# A path such as docs/x.md passes.
printf '%s\n' "$SEGMENTS" | grep -E '^git add ' |
  grep -E ' (-[a-zA-Z]*[Au][a-zA-Z]*|--all|--update|\.\.?/?|:/|\*)( |$)' > /dev/null &&
  staging "stage explicit paths (git add <path>), not the whole tree."
# git commit -a (or --all) stages every tracked change, so it sweeps the same way. In a
# cluster, a letter after one that takes a value (-m, -F, -C, -c, -t, -S, -u) is that value.
printf '%s\n' "$SEGMENTS" | grep -E '^git commit ' |
  grep -E ' (-[^-mFCctSu ]*a[a-zA-Z]*|--all)( |$)' > /dev/null &&
  staging "git commit -a or --all stages every tracked change. Stage explicit paths (git add <path>) and commit without it."

printf '%s\n' "$SEGMENTS" | grep -E '^git commit( |$)' > /dev/null && DECISION=$(strictest "$DECISION" "$COMMITS")
printf '%s\n' "$SEGMENTS" | grep -E '^git push( |$)' > /dev/null && DECISION=$(strictest "$DECISION" "$PUSHES")

case "$DECISION" in
  block)
    echo "Blocked: this project reviews git commits and pushes itself. Summarise the diff instead." >&2
    exit 2 ;;
  ask)
    # Exit 0 with this JSON shows the user a permission prompt instead of blocking the call.
    jq -cn --arg why "Git guard: check the staging, branch, remote and commits before you approve." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $why}}' \
      || { echo "Blocked: the git guard could not ask you about this command." >&2; exit 2; } ;;
esac
exit 0
```

`.claude/hooks/command-segments.awk` — split a command line into the commands it runs

```awk
# Prints each command a shell command line runs, one per line, so a guard can match a command
# where it starts rather than a phrase anywhere in the text. Reads the command line on stdin.
# - Quoted text becomes Q, except a bare ".", "..", "./", "../", ":/" or "*", which stays. A
#   $(...) or `...` inside double quotes is a command, not quoted text.
# - A heredoc's body and a # comment are data, so they are skipped.
# - ; & | ( ) { } ` and a newline end a command; find's -exec, -execdir, -ok and -okdir start one.
# - Shell keywords (if, then, do, !, coproc, ...), VAR=value words and wrappers (sudo, env, xargs,
#   timeout, ...) before rm or git are dropped, a path is stripped from rm and git, and git's
#   global options are dropped, so "sudo /bin/rm -rf d" reads "rm -rf d" and "git -C d push"
#   reads "git push".
# It reads text, not a shell. A variable, an alias, a command inside sh -c '...' or eval, and
# a script fed to a shell as a heredoc all get past it.
{ text = text $0 "\n" }
END {
  out = ""; q = ""; quoted = ""; nd = 0; sp = 0
  n = length(text)
  for (i = 1; i <= n; i++) {
    c = substr(text, i, 1)
    if (q == "'") {                                  # single quotes: jump to the closing one
      j = index(substr(text, i), "'")
      out = out kept(j ? substr(text, i, j - 1) : substr(text, i))
      i = j ? i + j - 1 : n; q = ""
      continue
    }
    if (q != "") {                                   # double quotes, or $'...' (q is "$")
      if ((q == "\"" && c == "\"") || (q == "$" && c == "'")) {
        out = out kept(quoted); q = ""; quoted = ""; continue
      }
      if (c == "\\" && i < n) { i++; quoted = quoted substr(text, i, 1); continue }
      if (q == "\"" && (c == "`" || (substr(text, i, 2) == "$(" && substr(text, i, 3) != "$(("))) {
        out = out kept(quoted) "\n"; quoted = ""; q = ""     # a command inside double quotes
        sp++; st[sp] = c; pd[sp] = 0
        if (c == "$") i++
        continue
      }
      quoted = quoted c
      continue
    }
    if (sp > 0) {                                    # inside "$(...)" or "`...`"
      if (st[sp] == "$" && c == "(") pd[sp]++
      else if ((st[sp] == "$" && c == ")" && pd[sp]-- == 0) || (st[sp] == "`" && c == "`")) {
        sp--; q = "\""; out = out "\n"; continue
      }
    }
    if (c == "'" || c == "\"") { q = c; continue }
    if (c == "$" && substr(text, i + 1, 1) == "'") { q = "$"; i++; continue }
    if (c == "#" && (i == 1 || substr(text, i - 1, 1) ~ /[ \t\n;&|()]/)) {
      j = index(substr(text, i), "\n"); i = j ? i + j - 2 : n; continue
    }
    if (c == "\\" && i < n) { i++; c = substr(text, i, 1); out = out (c == "\n" ? " " : c); continue }
    if (substr(text, i, 3) == "<<<") { out = out "<<<"; i += 2; continue }
    if (substr(text, i, 2) == "<<") { i = heredoc(i + 2); continue }
    if (c == "\n" && nd > 0) { i = skip_bodies(i); out = out "\n"; continue }
    if (index(";&|(){}`\n", c)) { out = out "\n"; continue }
    out = out c
  }
  gsub(/[ \t]-(exec|execdir|ok|okdir)[ \t]/, "\n", out)
  m = split(out, lines, "\n")
  for (l = 1; l <= m; l++) emit(lines[l])
}
function kept(s) { return s ~ /^(\.\.?\/?|:\/|\*)$/ ? s : "Q" }
function base(w) { sub(/^.*\//, "", w); return w }
# Reads the delimiter of a heredoc whose "<<" ends just before p; returns where it ends.
# A delimiter that starts with a digit or "=", or is followed by ")", is taken for a shift in
# arithmetic, as in $((1<<2)), $((1 << n)) or (( x <<= n )).
function heredoc(p,    d, e, j, strip, r) {
  strip = 0
  if (substr(text, p, 1) == "-") { strip = 1; p++ }
  while (substr(text, p, 1) ~ /[ \t]/) p++
  d = ""
  for (; p <= n; p++) {
    e = substr(text, p, 1)
    if (e == "'" || e == "\"") {
      j = index(substr(text, p + 1), e)
      if (!j) break
      d = d substr(text, p + 1, j - 1); p += j
    } else if (e == "\\") { p++; d = d substr(text, p, 1) }
    else if (e ~ /[ \t\n;&|()<>]/) break
    else d = d e
  }
  r = p
  while (substr(text, r, 1) ~ /[ \t]/) r++
  if (d != "" && d !~ /^[0-9=]/ && substr(text, r, 1) != ")") { nd++; delim[nd] = d; tabs[nd] = strip }
  return p - 1
}
# Skips the bodies of the heredocs opened on the line that ends at newline i.
function skip_bodies(i,    k, s, j, line) {
  for (k = 1; k <= nd; k++)
    while (i < n) {
      s = i + 1; j = index(substr(text, s), "\n")
      line = j ? substr(text, s, j - 1) : substr(text, s)
      i = j ? s + j - 1 : n
      if (tabs[k]) sub(/^\t+/, "", line)
      if (line == delim[k]) break
    }
  nd = 0
  return i
}
function emit(line,    t, k, i, j, cmd, rest) {
  k = split(line, t)
  i = 1
  while (i <= k && (t[i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || t[i] ~ /^(if|then|else|elif|do|while|until|coproc|!)$/)) i++
  if (i <= k && base(t[i]) ~ /^(sudo|doas|env|command|builtin|exec|nohup|nice|ionice|time|timeout|stdbuf|xargs)$/)
    while (i <= k && base(t[i]) !~ /^(rm|git)$/) i++
  if (i > k) return
  cmd = base(t[i++])
  if (cmd == "git")
    while (i <= k && t[i] ~ /^-/) {
      if (t[i] ~ /^(-C|-c|--git-dir|--work-tree|--namespace|--config-env)$/) i++
      i++
    }
  rest = cmd
  for (j = i; j <= k; j++) rest = rest " " t[j]
  print rest
}
```

## Appendix Q — git `commit-msg` hook

A Claude Code hook sees only Claude's tool calls. A git hook runs on each `git commit` in a clone where it is installed, whoever runs it, so it is where to enforce a convention that people follow too. This one checks two conventions the project names (§1, §8):

- The subject follows the commit style, Conventional Commits by default. Subjects in git's own forms pass: merges of branches, remote-tracking branches, tags and commits (`Merge branch …`, `Merge tags …` and the like), `Revert "…"` and `Reapply "…"`, and `fixup!`, `squash!` and `amend!` commits. A `git pull <url>` that merges the remote's default branch writes `Merge <url>`, which the hook refuses: pull a named branch instead.
- A `feat` or `fix` commit adds a non-blank line under `## [Unreleased]` in `CHANGELOG.md`, so the changelog entry lands in the same commit as the change (§8).

The settings sit at the top of the script: the subject pattern, the changelog's path, its Unreleased heading and `REQUIRE_CHANGELOG`. A project whose commit style has no `feat` or `fix` type changes the pattern and sets `REQUIRE_CHANGELOG=no`. An amend keeps the line the amended commit added, provided it keeps the subject or adds no change. An amend that rewords the subject and adds a change needs a line of its own in the index. A hook can't tell an amend from a new commit, so a new `feat` or `fix` commit that repeats the last commit's subject passes on that commit's line. The plugin ships the script as `plugin/skills/scaffold/templates/commit-msg`, and `plugin/scripts/tests/commit-msg.sh` checks it.

The hook runs after the git guard (Appendix C). The guard decides whether Claude may run `git commit` at all; the hook checks the message git is about to record. `git commit --no-verify` skips the hook, so like the guards it catches slips, not a determined bypass.

`.githooks/commit-msg` — check the subject, and the changelog line for a `feat` or `fix`

```sh
#!/bin/sh
# Git commit-msg hook: checks the subject against the project's commit style and, for a feat or
# fix commit, that the commit adds a line under the changelog's Unreleased heading. Git passes
# the message file as $1; a non-zero exit stops the commit. git commit --no-verify skips it.

# Settings. SUBJECT is the extended regular expression a subject must match: Conventional
# Commits by default. Set REQUIRE_CHANGELOG=no to drop the changelog check, as a project whose
# commit style has no feat or fix type should.
SUBJECT='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: [^ ]'
CHANGELOG=CHANGELOG.md
UNRELEASED='## [Unreleased]'   # the heading's start, as written
REQUIRE_CHANGELOG=yes

# The subject is the first line that is neither blank nor a comment, above any scissors line
# that git commit -v adds. core.commentChar sets the comment character; "auto" counts as #.
CC=$(git config core.commentChar 2>/dev/null || :)  # unset by default; Husky runs hooks with sh -e
case "$CC" in '' | auto) CC='#' ;; esac
MSG=$(c="$CC" awk 'index($0, ENVIRON["c"] " ------------------------ >8 ------------------------") == 1 { exit }
  index($0, ENVIRON["c"]) == 1 || $0 ~ /^[ \t]*$/ { next }
  { print; exit }' "$1")
if [ -z "$MSG" ]; then
  printf 'commit-msg: no subject line (lines starting with %s are comments).\n' "$CC" >&2
  exit 1
fi
case "$MSG" in  # git's own subjects
  "Merge branch "* | "Merge branches "* | "Merge remote-tracking branch "* | \
  "Merge remote-tracking branches "* | "Merge tag "* | "Merge tags "* | "Merge commit "* | \
  "Merge commits "* | 'Revert "'* | 'Reapply "'* | "fixup! "* | "squash! "* | "amend! "*) exit 0 ;;
esac
if ! printf '%s\n' "$MSG" | grep -Eq "$SUBJECT"; then
  echo "commit-msg: this subject doesn't follow the project's commit style." >&2
  printf '  subject: %s\n  pattern: %s\n' "$MSG" "$SUBJECT" >&2
  exit 1
fi
[ "$REQUIRE_CHANGELOG" = yes ] || exit 0
printf '%s\n' "$MSG" | grep -Eq '^(feat|fix)(\([^)]+\))?!?:' || exit 0

unreleased() { # rev prefix (":" for the index, "HEAD:"): the Unreleased section's first and last line
  git show "$1$CHANGELOG" 2>/dev/null | h="$UNRELEASED" awk '
    s && /^## / { print s, NR - 1; done = 1; exit }
    !s && index($0, ENVIRON["h"]) == 1 { s = NR }
    END { if (s && !done) print s, NR }'
}
adds_line() { # rev prefix, then a diff command: does its diff add a non-blank line there?
  range=$(unreleased "$1"); shift
  [ -n "$range" ] || return 1
  "$@" -- "$CHANGELOG" | awk -v r="$range" '
    BEGIN { split(r, u, " ") }
    /^@@/ { split($3, n, ","); line = substr(n[1], 2) + 0; hunk = 1; next }
    !hunk || /^-/ { next }
    /^\+/ { if (line > u[1] && line <= u[2] && substr($0, 2) ~ /[^ \t]/) found = 1; line++ }
    END { exit !found }'
}

if ! git cat-file -e ":$CHANGELOG" 2>/dev/null; then
  echo "commit-msg: a feat or fix commit adds a line to $CHANGELOG, and the index has no $CHANGELOG." >&2
  echo "  Set CHANGELOG to the changelog's path, or REQUIRE_CHANGELOG=no, at the top of this hook." >&2
  exit 1
fi
# Plumbing diffs, which ignore the user's colour and external-diff settings.
EMPTY=$(git hash-object -t tree /dev/null)
adds_line : git diff-index --cached -p -U0 "$(git rev-parse -q --verify HEAD || echo "$EMPTY")" &&
  exit 0
# An amend keeps the changes of the commit it replaces. When the index matches that commit, or
# the subject is unchanged, accept the line that commit added. A hook can't tell an amend from
# a new commit, so a new commit that repeats the last commit's subject passes too.
if git rev-parse -q --verify HEAD > /dev/null; then
  if git diff-index --cached --quiet HEAD ||
    [ "$(git log -1 --no-show-signature --format=%s HEAD)" = "$MSG" ]; then
    adds_line HEAD: git diff-tree -p -U0 "$(git rev-parse -q --verify 'HEAD^' || echo "$EMPTY")" HEAD &&
      exit 0
  fi
fi
printf 'commit-msg: a feat or fix commit adds a line under %s in %s.\n' "$UNRELEASED" "$CHANGELOG" >&2
echo "  Stage that line with the change, or set REQUIRE_CHANGELOG=no at the top of this hook." >&2
exit 1
```

Make it executable and point the clone's hooks at its directory:

```sh
chmod +x .githooks/commit-msg
```

```sh
git config core.hooksPath .githooks
```

`core.hooksPath` replaces `.git/hooks` and any global hooks path, so move any hooks already there into `.githooks/`. If the project already uses a hook manager, put the script where that manager keeps its hooks (for Husky, `.husky/commit-msg`) rather than in a directory it generates. If a `commit-msg` hook exists already, merge the two by hand. Each clone runs the `git config` line once.
