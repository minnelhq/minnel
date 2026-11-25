#!/bin/bash
# Table-driven check of the plugin's guard scripts: feeds each a sample PreToolUse
# payload on stdin and compares the result: 2 blocks, 0 allows, and ask means exit 0 with a
# permissionDecision of "ask" on stdout, which prompts the user. The last section runs
# config-audit.sh, the read-only script /retro starts from, against a throwaway project.
# Run from anywhere: plugin/scripts/tests/guards.sh. Run by another shell, it restarts under bash:
# dash can't parse the cases' bash quoting, and on macOS bash in POSIX mode (its sh, or
# POSIXLY_CORRECT set) expands the backslashes in the payloads' echo.
case ":${SHELLOPTS:-}:" in *:posix:*) posix=1 ;; *) posix= ;; esac
if { [ -z "${BASH_VERSION:-}" ] || [ -n "$posix" ]; } && [ -z "${MINNEL_GUARDS_REEXEC:-}" ]; then
  unset POSIXLY_CORRECT; MINNEL_GUARDS_REEXEC=1 exec bash "$0" "$@"
fi
CDPATH= cd -- "$(dirname -- "$0")/.." || exit 1
export CLAUDE_PROJECT_DIR=/proj
# Test the defaults, not this project's settings.
unset MINNEL_GIT_GUARD_STAGING MINNEL_GIT_GUARD_COMMITS MINNEL_GIT_GUARD_PUSHES MINNEL_BASH_GUARD
fail=0

bash_call() { jq -cn --arg c "$1" '{tool_name:"Bash", tool_input:{command:$c}}'; }
write_call() { jq -cn --arg a "$1" --arg f "$2" --arg c "${3:-x}" \
  '{tool_name:"Write", tool_input:{file_path:$f, content:$c}} + (if $a == "" then {} else {agent_type:$a} end)'; }

check() { # expected (0, 2 or ask) script payload label [env assignment]
  local want=$1 script=$2 payload=$3 label=$4 out got
  out=$(echo "$payload" | env ${5:+"$5"} "./$script" 2>/dev/null); got=$?
  if [ "$got" = 0 ] && [ "$(echo "$out" | jq -r '.hookSpecificOutput.permissionDecision? // empty' 2>/dev/null)" = ask ]; then
    got=ask
  fi
  if [ "$got" = "$want" ]; then echo "ok   $script  $label"
  else echo "FAIL $script  $label: want $want, got $got"; fail=1; fi
}

check 2 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A'
check 2 git-guard.sh  "$(bash_call 'git add --all')"       'git add --all'
check 2 git-guard.sh  "$(bash_call 'git add .')"           'git add .'
check 2 git-guard.sh  "$(bash_call 'git add ./')"          'git add ./'
check 0 git-guard.sh  "$(bash_call 'git commit -m x')"     'git commit'
check 0 git-guard.sh  "$(bash_call 'git commit --amend')"  'git commit --amend'
check 2 git-guard.sh  "$(bash_call 'git commit -am x')"    'git commit -am'
check 2 git-guard.sh  "$(bash_call 'git commit --all -m x')" 'git commit --all'
check ask git-guard.sh "$(bash_call 'git push')"           'git push'
check ask git-guard.sh "$(bash_call 'git commit -m x && git push')" 'git commit, then push'
check 0 git-guard.sh  "$(bash_call 'git add docs/x.md')"   'git add <path>'
check 0 git-guard.sh  "$(bash_call 'git status')"          'git status'
# Variants of blanket staging and commit -a.
check 2 git-guard.sh  "$(bash_call 'git add -Av')"         'git add -Av'
check 2 git-guard.sh  "$(bash_call 'git add -u')"          'git add -u'
check 2 git-guard.sh  "$(bash_call 'git add --update')"    'git add --update'
check 2 git-guard.sh  "$(bash_call 'git add ..')"          'git add ..'
check 2 git-guard.sh  "$(bash_call 'git add :/')"          'git add :/'
check 2 git-guard.sh  "$(bash_call 'git add -- .')"        'git add -- .'
check 2 git-guard.sh  "$(bash_call 'git add "."')"         'git add "."'
check 2 git-guard.sh  "$(bash_call "git add '.'")"         "git add '.'"
check 2 git-guard.sh  "$(bash_call 'git add .;')"          'git add .;'
check 2 git-guard.sh  "$(bash_call 'cd x && git add -A')"  'git add -A after &&'
check 2 git-guard.sh  "$(bash_call 'git -C x add .')"      'git -C x add .'
check 0 git-guard.sh  "$(bash_call 'git add ./docs/x.md')" 'git add ./<path>'
check 2 git-guard.sh  "$(bash_call 'git commit -qam x')"   'git commit -qam'
check 2 git-guard.sh  "$(bash_call 'git commit -vam x')"   'git commit -vam'
check 0 git-guard.sh  "$(bash_call 'git commit -mall')"    'git commit -m with an a in the message'
check 0 git-guard.sh  "$(bash_call 'git commit -m "see -a"')" 'git commit, -a inside the message'
check 0 git-guard.sh  "$(bash_call 'git commit -m x && git log --all')" 'git commit, then git log --all'
# A push after git's global options or a wrapper still asks; a mention of one doesn't.
check ask git-guard.sh "$(bash_call 'git -C ../repo push')" 'git -C <dir> push'
check ask git-guard.sh "$(bash_call 'git -c k=v push')"    'git -c k=v push'
check ask git-guard.sh "$(bash_call 'git --no-pager push')" 'git --no-pager push'
check ask git-guard.sh "$(bash_call 'GIT_SSH=x env git push')" 'git push after VAR= and env'
check 0 git-guard.sh  "$(bash_call 'echo "git push"')"     'git push inside quotes'
check 0 git-guard.sh  "$(bash_call "grep -n 'git push' f")" 'git push as a grep pattern'
check 0 git-guard.sh  "$(bash_call $'git commit -F - <<\'EOF\'\nthen git push\nEOF')" 'git push in a heredoc'
# A push behind a keyword, after a comment, or in a command substitution still asks.
check ask git-guard.sh "$(bash_call 'if true; then git push; fi')" 'git push after then'
check ask git-guard.sh "$(bash_call $'# it\'s done\ngit push')" 'git push after a comment with an apostrophe'
check ask git-guard.sh "$(bash_call 'out="$(git push origin main 2>&1)"')" 'git push in "$(...)"'
check ask git-guard.sh "$(bash_call 'echo "`git push`"')"  'git push in "`...`"'
check ask git-guard.sh "$(bash_call $'git commit -m "$(cat <<\'EOF\'\nfix: an odd " quote\nEOF\n)" && git push')" 'heredoc commit message, then git push'
check ask git-guard.sh "$(bash_call $'echo $\'it\\\'s\' && git push')" "git push after \$'...'"
# Accepted misses: the guard reads text, not a shell, so these get past it.
check 0 git-guard.sh  "$(bash_call "sh -c 'git push'")"    'accepted miss: push inside sh -c'
check 0 git-guard.sh  "$(bash_call 'G=git; $G add -A')"    'accepted miss: git in a variable'
check 2 git-guard.sh  "$(bash_call 'git commit -m x')"     'git commit, commits block' MINNEL_GIT_GUARD_COMMITS=block
check ask git-guard.sh "$(bash_call 'git commit -m x')"    'git commit, commits ask' MINNEL_GIT_GUARD_COMMITS=ask
check 0 git-guard.sh  "$(bash_call 'git push')"            'git push, pushes allow' MINNEL_GIT_GUARD_PUSHES=allow
check 2 git-guard.sh  "$(bash_call 'git push')"            'git push, pushes block' MINNEL_GIT_GUARD_PUSHES=block
check 2 git-guard.sh  "$(bash_call 'git push')"            'git push, unknown setting' MINNEL_GIT_GUARD_PUSHES=0
check 2 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A, pushes allow' MINNEL_GIT_GUARD_PUSHES=allow
check 2 git-guard.sh  "$(bash_call 'git commit -m x && git push')" 'commit then push, commits block' MINNEL_GIT_GUARD_COMMITS=block
check 0 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A, staging allow' MINNEL_GIT_GUARD_STAGING=allow
check ask git-guard.sh "$(bash_call 'git add -A')"         'git add -A, staging ask' MINNEL_GIT_GUARD_STAGING=ask
check 2 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A, staging block' MINNEL_GIT_GUARD_STAGING=block
check 2 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A, unknown setting' MINNEL_GIT_GUARD_STAGING=0
check ask git-guard.sh "$(bash_call 'git commit -am x')"   'git commit -am, staging ask' MINNEL_GIT_GUARD_STAGING=ask
check 0 git-guard.sh  "$(bash_call 'git commit -am x')"    'git commit -am, staging allow' MINNEL_GIT_GUARD_STAGING=allow
check ask git-guard.sh "$(bash_call 'git add -A && git push')" 'git add -A then push, staging allow' MINNEL_GIT_GUARD_STAGING=allow

check 2 bash-guard.sh "$(bash_call 'rm -rf /tmp/x')"       'rm -rf'
check 2 bash-guard.sh "$(bash_call 'git push --force')"    'git push --force'
check 0 bash-guard.sh "$(bash_call 'ls -la')"              'ls -la'
# rm's flags in any order, and rm behind a wrapper, a path or -exec.
check 2 bash-guard.sh "$(bash_call 'rm -fr x')"            'rm -fr'
check 2 bash-guard.sh "$(bash_call 'rm -r -f x')"          'rm -r -f'
check 2 bash-guard.sh "$(bash_call 'rm --recursive --force x')" 'rm --recursive --force'
check 2 bash-guard.sh "$(bash_call 'rm -Rf x')"            'rm -Rf'
check 2 bash-guard.sh "$(bash_call 'cd /tmp && rm -rf x')" 'rm -rf after &&'
check 2 bash-guard.sh "$(bash_call 'sudo -u root rm -rf x')" 'sudo -u root rm -rf'
check 2 bash-guard.sh "$(bash_call 'xargs -0 rm -rf')"     'xargs -0 rm -rf'
check 2 bash-guard.sh "$(bash_call 'timeout 5 rm -rf x')"  'timeout 5 rm -rf'
check 2 bash-guard.sh "$(bash_call 'find . -name x -exec rm -rf {} +')" 'find -exec rm -rf'
check 2 bash-guard.sh "$(bash_call '/bin/rm -rf x')"       '/bin/rm -rf'
check 2 bash-guard.sh "$(bash_call '\rm -rf x')"           '\rm -rf'
check 0 bash-guard.sh "$(bash_call 'rm -r x')"             'rm -r without -f'
check 0 bash-guard.sh "$(bash_call 'rm -f x')"             'rm -f without -r'
# Force pushes; --force-with-lease passes to the git guard, which asks.
check 2 bash-guard.sh "$(bash_call 'git push -f')"         'git push -f'
check 2 bash-guard.sh "$(bash_call 'git push origin +main')" 'git push +refspec'
check 2 bash-guard.sh "$(bash_call 'git -C x push --force')" 'git -C x push --force'
check 0 bash-guard.sh "$(bash_call 'git push --force-with-lease')" 'git push --force-with-lease'
# Mentions aren't commands (the false positives seen on 2026-11-23).
check 0 bash-guard.sh "$(bash_call "grep -E '\\brm -rf\\b' f")" 'rm -rf as a grep pattern'
check 0 bash-guard.sh "$(bash_call 'echo rm -rf x')"       'rm -rf as an argument'
check 0 bash-guard.sh "$(bash_call $'python3 - <<\'EOF\'\ns = "rm -rf"\nEOF')" 'rm -rf in a heredoc'
check 2 bash-guard.sh "$(bash_call $'cat <<EOF > f\nit\'s fine\nEOF\nrm -rf x')" 'rm -rf after a heredoc'
# rm behind a keyword, after a comment, or in a command substitution still blocks.
check 2 bash-guard.sh "$(bash_call 'for d in a b; do rm -rf "$d"; done')" 'rm -rf after do'
check 2 bash-guard.sh "$(bash_call '! git push -f')"       'git push -f after !'
check 2 bash-guard.sh "$(bash_call $'# it\'s a cleanup\nrm -rf build')" 'rm -rf after a comment with an apostrophe'
check 2 bash-guard.sh "$(bash_call 'echo "$(rm -rf x)"')"  'rm -rf in "$(...)"'
check 2 bash-guard.sh "$(bash_call 'x=$((1<<2)); rm -rf x')" 'rm -rf after a shift in $((...))'
check 2 bash-guard.sh "$(bash_call $'echo $((1<<n))\nrm -rf x')" 'rm -rf after a shift by a variable'
check 2 bash-guard.sh "$(bash_call $'(( x <<= n ))\nrm -rf x')" 'rm -rf after <<='
check 2 bash-guard.sh "$(bash_call 'coproc rm -rf x')"     'rm -rf after coproc'
check 2 bash-guard.sh "$(bash_call '/usr/bin/env rm -rf x')" 'rm -rf behind /usr/bin/env'
check 0 bash-guard.sh "$(bash_call 'echo "$(( 1 + 2 ))"; echo ${#a}')" 'arithmetic and ${#...}'
# DROP TABLE sits inside an argument, so it matches anywhere, a mention included.
check 2 bash-guard.sh "$(bash_call 'psql -c "DROP TABLE x"')" 'DROP TABLE in psql -c'
check 2 bash-guard.sh "$(bash_call 'git commit -m "explain DROP TABLE"')" 'accepted false positive: DROP TABLE in a message'
# Accepted misses: the guard reads text, not a shell, so these get past it.
check 0 bash-guard.sh "$(bash_call "sh -c 'rm -rf x'")"    'accepted miss: rm inside sh -c'
check 0 bash-guard.sh "$(bash_call 'eval "rm -rf x"')"     'accepted miss: rm inside eval'
check 0 bash-guard.sh "$(bash_call $'bash <<EOF\nrm -rf x\nEOF')" 'accepted miss: rm in a script fed as a heredoc'
check 0 bash-guard.sh "$(bash_call 'echo "$(case a in a) rm -rf x;; esac)"')" 'accepted miss: a case pattern inside "$(...)"'
check 0 bash-guard.sh "$(bash_call 'rm -rf x')"            'rm -rf, bash guard allow' MINNEL_BASH_GUARD=allow
check ask bash-guard.sh "$(bash_call 'rm -rf x')"          'rm -rf, bash guard ask' MINNEL_BASH_GUARD=ask
check ask bash-guard.sh "$(bash_call 'git push --force')"  'git push --force, bash guard ask' MINNEL_BASH_GUARD=ask
check 0 bash-guard.sh "$(bash_call 'ls -la')"              'ls -la, bash guard ask' MINNEL_BASH_GUARD=ask
check 2 bash-guard.sh "$(bash_call 'rm -rf x')"            'rm -rf, bash guard block' MINNEL_BASH_GUARD=block
check 2 bash-guard.sh "$(bash_call 'rm -rf x')"            'rm -rf, unknown setting' MINNEL_BASH_GUARD=0

# Without command-segments.awk beside them, the guards block rather than pass everything.
lone=$(mktemp -d) && cp bash-guard.sh git-guard.sh "$lone"/
for g in bash-guard.sh git-guard.sh; do
  bash_call 'ls' | "$lone/$g" 2>/dev/null
  if [ $? = 2 ]; then echo "ok   $g  blocks without command-segments.awk"
  else echo "FAIL $g  blocks without command-segments.awk"; fail=1; fi
done
rm -r "$lone"

check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/src/a.py)"        'test-writer, src/'
check 0 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/tests/test_a.py)" 'test-writer, tests/'
check 0 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/pkg/__tests__/a.js)" 'test-writer, __tests__/'
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/tests/../src/a.py)"  'test-writer, tests/../src/'
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/tests/..)"            'test-writer, trailing ..'
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /tmp/tests/a.py)"          'test-writer, outside project'
check 0 tests-dir-guard.sh "$(write_call '' /proj/src/a.py)"                             'main session, src/'
check 0 tests-dir-guard.sh "$(write_call minnel:code-reviewer /proj/src/a.py)"      'other agent, src/'

# With POSIXLY_CORRECT set, macOS bash's echo expands the payload's \n and \t, the JSON stops
# parsing and a guard reading it with echo lets the call through. The guards read it with printf.
check 2 bash-guard.sh "$(bash_call $'cd x\nrm -rf build')" 'rm -rf on a second line, POSIXLY_CORRECT set' POSIXLY_CORRECT=1
check ask git-guard.sh "$(bash_call $'cd x\ngit push')"    'git push on a second line, POSIXLY_CORRECT set' POSIXLY_CORRECT=1
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/src/a.py $'a\nb')" 'test-writer, multi-line content, POSIXLY_CORRECT set' POSIXLY_CORRECT=1
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer $'/proj/src/a\tb.py')" 'test-writer, a tab in the path, POSIXLY_CORRECT set' POSIXLY_CORRECT=1

# config-audit.sh: a throwaway project and home, each naming paths that exist and paths that don't.
audit_dir=$(mktemp -d) && mkdir -p "$audit_dir/proj/docs" "$audit_dir/proj/.claude/agent-memory/r" \
  "$audit_dir/proj/.claude/skills/x" "$audit_dir/home/.claude/rules"
touch "$audit_dir/proj/docs/here.md" "$audit_dir/proj/.claude/skills/x/SKILL.md" "$audit_dir/proj/docs/c.json"
printf '%s\n' 'Gone: `docs/gone.md`, @docs/imported.md' \
  'Here: [h](docs/here.md), `docs/here.md:12`, `./docs/`' \
  'Not paths: `/release`, `plans/`, `src/**/*.py`, `<name>/x.md`, `${CLAUDE_PLUGIN_ROOT}/x.sh`, `https://example.com/a.md`, `git@example.com:o/r.git`' \
  '@docs/linestart.md' \
  > "$audit_dir/proj/CLAUDE.md"
printf '%s\n' 'Beside it: `../../../docs/here.md`; by its tail: `x/SKILL.md`, `./x/SKILL.md`; gone: `.claude/agents/old.md`, `docs/c.js`, `node_modules/@types/gone/index.d.ts`' \
  > "$audit_dir/proj/.claude/agent-memory/r/note.md"
printf '%s\n' 'Gone: `~/.claude/gone.sh`. Here: `~/.claude/rules/r.md`. Another project'"'"'s: `docs/other.md`' \
  > "$audit_dir/home/.claude/rules/r.md"
mkdir -p "$audit_dir/home/.claude/agent-memory/a"
printf '%s\n' 'Gone: `docs/dotclaude-gone.md`' > "$audit_dir/proj/.claude/CLAUDE.md"
printf '%s\n' 'Gone: `docs/gone-in-local-file.md`' > "$audit_dir/proj/CLAUDE.local.md"
printf '%s\n' 'Gone: `~/.claude/am-gone.md`' > "$audit_dir/home/.claude/agent-memory/a/n.md"
git -C "$audit_dir/proj" init -q && git -C "$audit_dir/proj" add .claude/skills/x/SKILL.md docs/c.json
mkdir -p "$audit_dir/shared" && printf '%s\n' 'Gone: `~/.claude/linked-gone.sh`' > "$audit_dir/shared/linked.md"
ln -s "$audit_dir/shared/linked.md" "$audit_dir/home/.claude/rules/linked.md"
audit_out=$(CLAUDE_PROJECT_DIR="$audit_dir/proj" HOME="$audit_dir/home" sh ./config-audit.sh 2>&1)
audit_rc=$?
audit() { # has|lacks text label
  case "$audit_out" in *"$2"*) found=has ;; *) found=lacks ;; esac
  if [ "$found" = "$1" ]; then echo "ok   config-audit.sh  $3"
  else echo "FAIL config-audit.sh  $3: output $found '$2'"; fail=1; fi
}
[ "$audit_rc" = 0 ] && echo "ok   config-audit.sh  exits 0" || { echo "FAIL config-audit.sh  exits 0: got $audit_rc"; fail=1; }
audit has   '     4  CLAUDE.md'                                'line count of CLAUDE.md'
audit has   '~/.claude/rules/r.md'                             'lists a user rule'
audit has   'CLAUDE.md:1: docs/gone.md'                        'a missing code-span path'
audit has   'CLAUDE.md:1: docs/imported.md'                    'a missing @import'
audit has   'CLAUDE.md:4: docs/linestart.md'                   'a missing @import at the start of a line'
audit has   'note.md:1: docs/c.js'                             'a file whose name only begins a project file'
audit has   'linked.md:1: ~/.claude/linked-gone.sh'            'a symlinked user rule'
audit has   '.claude/CLAUDE.md:1: docs/dotclaude-gone.md'      'reads .claude/CLAUDE.md'
audit has   'CLAUDE.local.md:1: docs/gone-in-local-file.md'    'reads CLAUDE.local.md'
audit has   'n.md:1: ~/.claude/am-gone.md'                     'reads user agent memory'
audit has   'note.md:1: node_modules/@types/gone/index.d.ts'   'a missing path with an @ in it'
audit has   'note.md:1: .claude/agents/old.md'                 'a missing path in agent memory'
audit has   'r.md:1: ~/.claude/gone.sh'                        'a missing ~/ path in a user rule'
audit lacks 'here.md'                                          'present paths, a :line suffix and ../ included'
audit lacks 'x/SKILL.md'                                       'a path that ends a project file'
audit lacks ': ./x/SKILL.md'                                   'a ./ path that ends a project file'
audit lacks ': ./docs/'                                        'a present directory'
audit lacks '/release'                                         'skips a slash command'
audit lacks 'plans/'                                           'skips a bare directory name'
audit lacks '*.py'                                             'skips a glob'
audit lacks '<name>'                                           'skips a placeholder'
audit lacks 'CLAUDE_PLUGIN_ROOT'                               'skips a variable'
audit lacks 'example.com'                                      'skips a URL and a git remote'
audit lacks 'docs/other.md'                                    'skips a relative path in a user rule'
empty_out=$(CLAUDE_PROJECT_DIR="$audit_dir/none" HOME="$audit_dir/none" sh ./config-audit.sh 2>&1); empty_rc=$?
case "$empty_rc:$empty_out" in
  0:*"  none"*) echo "ok   config-audit.sh  no files: exits 0 and reports none" ;;
  *) echo "FAIL config-audit.sh  no files: got $empty_rc"; fail=1 ;;
esac
rm -r "$audit_dir"

exit $fail
