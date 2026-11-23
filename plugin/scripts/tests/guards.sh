#!/bin/bash
# Table-driven check of the plugin's guard scripts: feeds each a sample PreToolUse
# payload on stdin and compares the exit code (2 blocks, 0 allows).
# Run from anywhere: plugin/scripts/tests/guards.sh
cd "$(dirname "$0")/.." || exit 1
export CLAUDE_PROJECT_DIR=/proj
fail=0

bash_call() { jq -cn --arg c "$1" '{tool_name:"Bash", tool_input:{command:$c}}'; }
write_call() { jq -cn --arg a "$1" --arg f "$2" \
  '{tool_name:"Write", tool_input:{file_path:$f, content:"x"}} + (if $a == "" then {} else {agent_type:$a} end)'; }

check() { # expected-exit script payload label [env assignment]
  local want=$1 script=$2 payload=$3 label=$4 got
  if [ -n "$5" ]; then got=$(echo "$payload" | env "$5" "./$script" 2>/dev/null; echo $?)
  else got=$(echo "$payload" | "./$script" 2>/dev/null; echo $?); fi
  if [ "$got" = "$want" ]; then echo "ok   $script  $label"
  else echo "FAIL $script  $label: want $want, got $got"; fail=1; fi
}

check 2 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A'
check 2 git-guard.sh  "$(bash_call 'git add --all')"       'git add --all'
check 2 git-guard.sh  "$(bash_call 'git add .')"           'git add .'
check 2 git-guard.sh  "$(bash_call 'git add ./')"          'git add ./'
check 2 git-guard.sh  "$(bash_call 'git commit -m x')"     'git commit'
check 2 git-guard.sh  "$(bash_call 'git push')"            'git push'
check 0 git-guard.sh  "$(bash_call 'git add docs/x.md')"   'git add <path>'
check 0 git-guard.sh  "$(bash_call 'git status')"          'git status'
check 0 git-guard.sh  "$(bash_call 'git commit -m x')"     'git commit, opted out' MINNEL_GIT_GUARD_COMMITS=0
check 2 git-guard.sh  "$(bash_call 'git add -A')"          'git add -A, opted out' MINNEL_GIT_GUARD_COMMITS=0

check 2 bash-guard.sh "$(bash_call 'rm -rf /tmp/x')"       'rm -rf'
check 2 bash-guard.sh "$(bash_call 'git push --force')"    'git push --force'
check 0 bash-guard.sh "$(bash_call 'ls -la')"              'ls -la'

check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/src/a.py)"        'test-writer, src/'
check 0 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/tests/test_a.py)" 'test-writer, tests/'
check 0 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/pkg/__tests__/a.js)" 'test-writer, __tests__/'
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/tests/../src/a.py)"  'test-writer, tests/../src/'
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /proj/tests/..)"            'test-writer, trailing ..'
check 2 tests-dir-guard.sh "$(write_call minnel:test-writer /tmp/tests/a.py)"          'test-writer, outside project'
check 0 tests-dir-guard.sh "$(write_call '' /proj/src/a.py)"                             'main session, src/'
check 0 tests-dir-guard.sh "$(write_call minnel:code-reviewer /proj/src/a.py)"      'other agent, src/'

exit $fail
