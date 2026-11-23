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
