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
says() { # message, text the hook's output must contain, label [hook]
  printf '%s\n' "$1" > "$tmp/msg"
  if "${4:-$HOOK}" "$tmp/msg" 2>&1 | grep -qF -- "$2"; then echo "ok   $3"
  else echo "FAIL $3: no '$2' in the output"; fail=1; fi
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
check 0 'Reapply "feat: add x"'                  "git's subject for a revert of a revert"
check 0 "Merge branches 'a' and 'b'"             'an octopus merge'
check 0 "Merge remote-tracking branch 'origin/a'" 'a merge of a remote-tracking branch'
check 0 "Merge remote-tracking branches 'origin/a' and 'origin/b'" 'an octopus of remote-tracking branches'
check 0 "Merge tag 'v1'"                         'a merge of a tag'
check 0 "Merge tags 'v1' and 'v2'"               'an octopus of tags'
check 0 'Merge commit 0123abc'                   'a merge of a commit'
check 0 'Merge commits 0123abc and 4567def'      'an octopus of commits'
check 1 'Merge the two parsers'                  'a subject that only starts with Merge'
# Comments follow core.commentChar, and the scissors line from git commit -v ends the message.
git config core.commentChar ';'
check 0 "$(printf '; a comment\ndocs: x')"       'a comment in core.commentChar'
git config core.commentChar auto
check 0 "$(printf '# a comment\ndocs: x')"       'core.commentChar auto counts # as the comment'
git config --unset core.commentChar
check 1 "$(printf '\n# ------------------------ >8 ------------------------\ndiff --git a/x b/x')" \
                                                 'no subject above the scissors'
check 1 '#42 tidy the parser'                    'a message that is all comment lines'
check 1 "$(printf 'Update x\n# ------------------------ >8 ------------------------\ndocs: x')" \
                                                 'a subject above the scissors, a valid one below'
says 'Update a\cb then' 'subject: Update a\cb then' 'a backslash in the subject is echoed whole'

# A feat or fix commit adds a line under Unreleased.
repo; change b
check 1 'feat: add b'                            'feat without a changelog line'
check 1 'fix(io): handle b'                      'fix with a scope, without a changelog line'
check 1 'feat!: drop a'                          'breaking feat without a changelog line'
check 0 'docs: explain b'                        'docs needs no changelog line'
unreleased_line 'Added b.'
check 0 'feat: add b'                            'feat with a line under Unreleased'
check 0 'fix(io)!: handle b'                     'fix with a scope and !, with the line'

# Hook managers such as Husky run the hook with sh -e, where any failing command ends it.
printf '#!/bin/sh\nexec sh -e "%s" "$@"\n' "$HOOK" > "$tmp/husky" && chmod +x "$tmp/husky"
repo; change b
check 0 'docs: x'                                'run under sh -e, as Husky does' "$tmp/husky"
check 1 'feat: add b'                            'under sh -e, feat without a line' "$tmp/husky"
unreleased_line 'Added b.'
check 0 'feat: add b'                            'under sh -e, feat with a line' "$tmp/husky"

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
says 'feat: add b' 'Set CHANGELOG' 'no changelog in the index: the message names the settings'
sed 's/^REQUIRE_CHANGELOG=yes$/REQUIRE_CHANGELOG=no/' "$HOOK" > "$tmp/no-changelog" && chmod +x "$tmp/no-changelog"
check 0 'feat: add b'                            'REQUIRE_CHANGELOG=no' "$tmp/no-changelog"
check 1 'Update b'                               'REQUIRE_CHANGELOG=no still checks the subject' "$tmp/no-changelog"

# The changelog's path and its Unreleased heading are settings.
repo; mkdir docs; printf '# Changelog\n\n## Unreleased\n\n## 0.1.0\n- The first release.\n' > docs/CHANGELOG.md
git add docs/CHANGELOG.md; git commit -q --no-verify -m 'chore: move the changelog'; change b
sed -e 's|^CHANGELOG=CHANGELOG.md$|CHANGELOG=docs/CHANGELOG.md|' \
    -e "s|^UNRELEASED='## \\[Unreleased\\]'|UNRELEASED='## Unreleased'|" "$HOOK" > "$tmp/elsewhere"
chmod +x "$tmp/elsewhere"
check 1 'feat: add b'                            'another path and heading, no line' "$tmp/elsewhere"
says 'feat: add b' 'under ## Unreleased in docs/CHANGELOG.md' 'the message names the heading set' "$tmp/elsewhere"
printf '# Changelog\n\n## Unreleased\n- Added b.\n\n## 0.1.0\n- The first release.\n' > docs/CHANGELOG.md
git add docs/CHANGELOG.md
check 0 'feat: add b'                            'another path and heading, with the line' "$tmp/elsewhere"

# An amend keeps the line the amended commit added.
repo; change b; unreleased_line 'Added b.'; git commit -q --no-verify -m 'feat: add b'
check 0 'feat: add b, reworded'                  'amend that only rewords'
change c
check 0 'feat: add b'                            'amend that adds a change and keeps the subject'
check 1 'feat: add b and c'                      'accepted miss: amend that rewords and adds a change'
repo; change b; git commit -q --no-verify -m 'feat: add b'
check 1 'feat: add b'                            'amend of a commit that added no line'
# A hook can't tell an amend from a new commit, so one that repeats the subject passes.
repo; change b; unreleased_line 'Fixed b.'; git commit -q --no-verify -m 'fix: lint'; change c
check 0 'fix: lint'                              "accepted pass: a new commit that repeats HEAD's subject"
# log.showSignature adds lines before the subject of a signed HEAD; the amend check ignores them.
if command -v ssh-keygen > /dev/null; then
  repo; ssh-keygen -q -t ed25519 -N '' -f "$tmp/key" > /dev/null
  git config gpg.format ssh; git config user.signingkey "$tmp/key.pub"
  change b; unreleased_line 'Added b.'; git commit -q --no-verify -S -m 'feat: add b'
  git config log.showSignature true; change c
  check 0 'feat: add b'                          'amend of a signed HEAD with log.showSignature on'
else echo 'skip amend of a signed HEAD: no ssh-keygen'; fi
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
