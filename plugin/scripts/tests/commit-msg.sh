#!/bin/sh
# Checks the commit-msg hook the scaffold installs (Appendix Q). Each case sets up a throwaway
# repository, stages a change, writes a commit message to a file and runs the hook on it, as git
# does: 0 lets the commit through, 1 stops it.
# Run from anywhere: plugin/scripts/tests/commit-msg.sh
CDPATH= cd -- "$(dirname -- "$0")/../../skills/scaffold/templates" || exit 1
HOOK="$PWD/commit-msg"
tmp=$(mktemp -d) || exit 1
trap 'rm -r "$tmp"' EXIT
trap 'exit 130' INT; trap 'exit 143' TERM
fail=0
n=0

CL_HEAD='# Changelog

## [Unreleased]
'
CL_OLD='
## [0.1.0] - 2026-01-01

### Added
- The first release.
'

repo() { # a fresh repository with a first commit holding the changelog; cd into it
  n=$((n + 1)); r="$tmp/r$n"
  git init -q "$r" && cd "$r" || exit 1
  git config user.name t; git config user.email t@example.invalid; git config commit.gpgsign false
  printf '%s%s' "$CL_HEAD" "$CL_OLD" > CHANGELOG.md
  echo a > a.txt
  git add CHANGELOG.md a.txt && git commit -q --no-verify -m 'chore: start'
}
unreleased_line() { # add a line under Unreleased, and stage it
  printf '%s\n### Added\n- %s\n%s' "$CL_HEAD" "$1" "$CL_OLD" > CHANGELOG.md && git add CHANGELOG.md
}
change() { echo "$1" >> a.txt && git add a.txt; }
check() { # expected (0 or 1), message, label [hook to run in place of the shipped one]
  printf '%s\n' "$2" > "$tmp/msg"
  "${4:-$HOOK}" "$tmp/msg" 2>/dev/null; got=$?
  [ "$got" -gt 1 ] && got="$got (error)"
  if [ "$got" = "$1" ]; then echo "ok   $3"
  else echo "FAIL $3: want $1, got $got"; fail=1; fi
}

# The subject follows the commit style: Conventional Commits by default.
repo; change b
check 0 'docs: say what the hook does'          'a conventional subject'
check 0 'refactor(api)!: drop the old route'     'a scope and a breaking-change mark'
check 1 'Update stuff'                           'a subject with no type'
check 1 'docs:say it'                            'no space after the colon'
check 1 'feature: add x'                         'a type the pattern does not list'
check 0 "$(printf '# a comment\n\ndocs: x')"     'comment and blank lines before the subject'
# Git's own subjects pass whatever the style.
check 0 "Merge branch 'topic'"                   'a merge commit'
check 0 'Revert "feat: add x"'                   "git's revert subject"
check 0 'fixup! feat: add x'                     'a fixup! commit'
check 0 'squash! feat: add x'                    'a squash! commit'
check 0 'amend! feat: add x'                     'an amend! commit'

# A feat or fix commit adds a line under Unreleased.
repo; change b
check 1 'feat: add b'                            'feat without a changelog line'
check 1 'fix(io): handle b'                      'fix with a scope, without a changelog line'
check 1 'feat!: drop a'                          'breaking feat without a changelog line'
check 0 'docs: explain b'                        'docs needs no changelog line'
unreleased_line 'Added b.'
check 0 'feat: add b'                            'feat with a line under Unreleased'
check 0 'fix(io)!: handle b'                     'fix with a scope and !, with the line'

repo; change b
printf '%s%s\n- Also b.\n' "$CL_HEAD" "$CL_OLD" > CHANGELOG.md && git add CHANGELOG.md
check 1 'feat: add b'                            'a line under an older release, not Unreleased'
repo; change b
printf '%s\n\n%s' "$CL_HEAD" "$CL_OLD" > CHANGELOG.md && git add CHANGELOG.md
check 1 'feat: add b'                            'only a blank line under Unreleased'
repo; change b
unreleased_line 'Added b.' && git reset -q CHANGELOG.md
check 1 'feat: add b'                            'the changelog line is written but not staged'

# Without a changelog in the index, the message names the settings.
repo; git rm -q --cached CHANGELOG.md; change b
check 1 'feat: add b'                            'no changelog in the index'
printf 'feat: add b\n' > "$tmp/msg"
if "$HOOK" "$tmp/msg" 2>&1 | grep -q 'Set CHANGELOG'; then echo 'ok   no changelog in the index: the message names the settings'
else echo 'FAIL no changelog in the index: the message names the settings'; fail=1; fi
sed 's/^REQUIRE_CHANGELOG=yes$/REQUIRE_CHANGELOG=no/' "$HOOK" > "$tmp/no-changelog" && chmod +x "$tmp/no-changelog"
check 0 'feat: add b'                            'REQUIRE_CHANGELOG=no' "$tmp/no-changelog"
check 1 'Update b'                               'REQUIRE_CHANGELOG=no still checks the subject' "$tmp/no-changelog"

# An amend keeps the line the amended commit added.
repo; change b; unreleased_line 'Added b.'; git commit -q --no-verify -m 'feat: add b'
check 0 'feat: add b, reworded'                  'amend that only rewords'
change c
check 0 'feat: add b'                            'amend that adds a change and keeps the subject'
check 1 'feat: add b and c'                      'accepted miss: amend that rewords and adds a change'
repo; change b; git commit -q --no-verify -m 'feat: add b'
check 1 'feat: add b'                            'amend of a commit that added no line'
# The first commit in a repository.
n=$((n + 1)); git init -q "$tmp/r$n" && cd "$tmp/r$n" || exit 1
git config user.name t; git config user.email t@example.invalid
unreleased_line 'The first feature.'
check 0 'feat: start'                            'first commit with a line under Unreleased'

# Installed through core.hooksPath, git runs it on a real commit, colour settings and all.
repo; mkdir hooks && cp "$HOOK" hooks/ && git config core.hooksPath hooks; change b
git config color.ui always
if git commit -q -m 'feat: add b' 2>/dev/null; then echo 'FAIL git commit, feat without a line: committed'; fail=1
else echo 'ok   git commit, feat without a line: refused'; fi
unreleased_line 'Added b.'
if git commit -q -m 'feat: add b' 2>/dev/null; then echo 'ok   git commit, feat with a line: committed'
else echo 'FAIL git commit, feat with a line: refused'; fail=1; fi

exit $fail
