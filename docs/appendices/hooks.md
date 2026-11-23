# Methodology appendices — hooks

Drop-in project hooks for the methodology. Companion to `../methodology.md`; the full index is in this directory's `README.md`.

## Appendix C — project hooks

The plugin ships the two guards as `plugin/scripts/bash-guard.sh` and `plugin/scripts/git-guard.sh`, wired in `plugin/hooks/hooks.json`. Its `git-guard.sh` adds per-project settings for how it treats commits and pushes.

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
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
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
```

`.claude/hooks/git-guard.sh` — block blanket staging, and ask before a push (§9)

```bash
#!/bin/bash
# Add as a second PreToolUse "Bash" hook, or fold into bash-guard.sh.
# A tripwire for slips, not a sandbox: command-segments.awk, kept beside this script, reads the
# command as text, so a command hidden in a variable, an alias or sh -c '...' gets past it.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
SEG_AWK="$(dirname "$0")/command-segments.awk"
[ -r "$SEG_AWK" ] || { echo "Blocked: $SEG_AWK is missing; keep it beside this guard." >&2; exit 2; }
SEGMENTS=$(printf '%s\n' "$COMMAND" | awk -f "$SEG_AWK")

# Blanket adds sweep up other sessions' files and ignored artefacts: -A, --all, -u, --update,
# or the whole tree as a path (., .., ./, :/, *). A path such as docs/x.md passes.
if printf '%s\n' "$SEGMENTS" | grep -E '^git add ' |
  grep -E ' (-[a-zA-Z]*[Au][a-zA-Z]*|--all|--update|\.\.?/?|:/|\*)( |$)' > /dev/null; then
  echo "Blocked: stage explicit paths (git add <path>), not the whole tree." >&2
  exit 2
fi
# git commit -a (or --all) stages every tracked change, so it sweeps the same way. In a
# cluster, a letter after one that takes a value (-m, -F, -C, -c, -t, -S, -u) is that value.
if printf '%s\n' "$SEGMENTS" | grep -E '^git commit ' |
  grep -E ' (-[^-mFCctSu ]*a[a-zA-Z]*|--all)( |$)' > /dev/null; then
  echo "Blocked: git commit -a or --all stages every tracked change. Stage explicit paths (git add <path>) and commit without it." >&2
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
printf '%s\n' "$SEGMENTS" | grep -E '^git commit( |$)' > /dev/null && DECISION=$(strictest "$DECISION" "$COMMITS")
printf '%s\n' "$SEGMENTS" | grep -E '^git push( |$)' > /dev/null && DECISION=$(strictest "$DECISION" "$PUSHES")

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

`.claude/hooks/command-segments.awk` — split a command line into the commands it runs

```awk
# Prints each command a shell command line runs, one per line, so a guard can match a command
# where it starts rather than a phrase anywhere in the text. Reads the command line on stdin.
# - Quoted text becomes Q, except a bare ".", "..", "./", "../", ":/" or "*", which stays. A
#   $(...) or `...` inside double quotes is a command, not quoted text.
# - A heredoc's body and a # comment are data, so they are skipped.
# - ; & | ( ) { } ` and a newline end a command; find's -exec, -execdir, -ok and -okdir start one.
# - Shell keywords (if, then, do, !, ...), VAR=value words and wrappers (sudo, env, xargs,
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
# A delimiter starting with a digit is taken for a shift, as in $((1<<2)).
function heredoc(p,    d, e, j, strip) {
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
  if (d != "" && d !~ /^[0-9]/) { nd++; delim[nd] = d; tabs[nd] = strip }
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
  while (i <= k && (t[i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || t[i] ~ /^(if|then|else|elif|do|while|until|!)$/)) i++
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
