#!/usr/bin/env bash
# docs-consistency.sh — PostToolUse hook (matcher: Edit|Write|MultiEdit).
#
# Catches, at edit time, four defect classes the code-reviewer keeps finding by
# hand in the product docs:
#   A) dangling cross-references — a §N or "Appendix X" that points at no real
#      heading (sections validated against methodology.md, appendices against
#      docs/appendices/*.md);
#   B) US spellings — the house style is British (-ise); a curated, exact-word
#      list flags the unambiguous American forms;
#   C) broken intra-repo links — a [text](path) whose target file does not exist,
#      resolved relative to the edited file (fenced code blocks are skipped); and
#   D) British DD/MM/YYYY dates — the repo's date format is ISO YYYY-MM-DD, so a
#      dd/mm/yyyy date is a regression (fenced code blocks skipped, as for C); and
#   E) appendix–plugin drift — each artefact the plugin ships also appears in an
#      appendix (or templates/), and the two copies must match once the intended
#      differences in the PAIRS table are normalised away.
#
# The edited file arrives as .tool_input.file_path in the JSON on stdin (the
# field is identical for Edit, Write and MultiEdit). PostToolUse runs after the
# edit, so it cannot block; exit 2 surfaces findings to Claude as actionable
# feedback. Exit 0 when the file is clean or out of scope.
#
# Scope: docs/**/*.md (except gitignored files and docs/plans/), README.md,
# CHANGELOG.md, templates/*.md. Check E also runs on edits under plugin/ (any file
# type), and only Check E runs there. Out: .claude/** (quoted config and tool names
# trip the spelling list), docs/plans/ (plans and meta-docs legitimately discuss
# references that don't resolve yet), LICENSE/NOTICE (intentionally American),
# non-Markdown.
#
# Known limitations: (1) runs per-file — a single batch that adds "## 11." to
# methodology.md *and* a §11 reference elsewhere may flag the reference until
# methodology.md's own edit lands; a re-edit clears it. (2) Check A matches the
# singular "Appendix X"; plural "Appendices A & C" forms are skipped (safe
# under-flagging, not a block). (3) Check C resolves only inline [text](path)
# links to relative paths; reference-style links, absolute "/..." paths, scheme
# links (anything with a colon), and links inside fenced code blocks are not checked.
# (4) Check E compares only the artefact itself: the prose the scaffold wraps around
# the D and G skeletons, and Appendix H's example versions, are never compared.
#
# POSIX sh only (no process substitution, no arrays), so a lost exec bit that
# routes this through /bin/sh still parses and runs rather than failing closed.

set -u

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# jq parses the hook payload; without it the hook is a no-op rather than a block.
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -n "$FILE" ] || exit 0
[ -f "$FILE" ] || exit 0

# Path relative to repo root, for scope matching.
case "$FILE" in
  "$ROOT"/*) REL="${FILE#"$ROOT"/}" ;;
  /*)        exit 0 ;;            # absolute path outside the repo — ignore
  *)         REL="$FILE" ;;
esac

# --- Check E: appendix–plugin drift (runs before the Markdown-only gate) ---
# Each PAIRS row: left file | left part | left normaliser | right file | right part |
# right normaliser | label. A part is "whole" or a marker: the first fenced block after
# the first line containing the marker. Normalisers remove the intended differences:
#   drop_hooks       B's frontmatter hooks: block (plugin agents ignore it)
#   drop_optout      git-guard's plugin opt-out lines
#   drop_skill_keys  the skill-only frontmatter keys (name, argument-hint,
#                    disable-model-invocation); applied to the plugin side only, so
#                    any other frontmatter field on either side is still compared
#   head_unreleased  Appendix H up to [Unreleased] (the template drops the examples)
# Blank-line runs are squeezed on both sides. Every pair is compared on each
# relevant edit, so a change to either side surfaces the drift. Each plugin skill
# must also keep disable-model-invocation: true, which the docs promise.
fence_part() { # file marker
  if [ "$2" = whole ]; then cat "$1"; return; fi
  awk -v m="$2" '!found { if (index($0, m)) found = 1; next }
    /^```/ { if (inb) exit; inb = 1; next }
    inb { print }' "$1"
}
normalise() { # mode, stdin
  case "$1" in
    drop_hooks)      awk '/^hooks:/ { d = 1; next } d && /^[^ ]/ { d = 0 } !d' ;;
    drop_optout)     awk '/^# Plugin opt-out:/ { d = 1 } !d { print } d && /MINNEL_GIT_GUARD_COMMITS:-1/ { d = 0 }' ;;
    drop_skill_keys) awk 'NR == 1 && /^---$/ { fm = 1; print; next }
                          fm && /^---$/ { fm = 0 }
                          fm && /^(name|argument-hint|disable-model-invocation):/ { next }
                          { print }' ;;
    head_unreleased) awk '{ print } /^## \[Unreleased\]/ { exit }' ;;
    *)               cat ;;
  esac | awk 'NF || !b { print } { b = !NF }'
}
check_e() {
  e_out=""
  while IFS='|' read -r lf lp ln rf rp rn label; do
    [ -n "$lf" ] || continue
    if [ ! -f "$ROOT/$lf" ] || [ ! -f "$ROOT/$rf" ]; then
      e_out="${e_out}  drift: ${label} — missing ${lf} or ${rf}\n"; continue
    fi
    left=$(fence_part "$ROOT/$lf" "$lp" | normalise "$ln")
    right=$(fence_part "$ROOT/$rf" "$rp" | normalise "$rn")
    if [ -z "$left" ] || [ -z "$right" ]; then  # a moved marker must not pass as empty == empty
      e_out="${e_out}  drift: ${label} — nothing extracted from ${lf} or ${rf}; check the PAIRS marker\n"; continue
    fi
    [ "$left" = "$right" ] || e_out="${e_out}  drift: ${label} — ${lf} and ${rf} differ; change both together\n"
  done <<'PAIRS'
docs/appendices/subagents.md|`.claude/agents/code-reviewer.md`|-|plugin/agents/code-reviewer.md|whole|-|Appendix A
docs/appendices/subagents.md|`.claude/agents/test-writer.md`|drop_hooks|plugin/agents/test-writer.md|whole|-|Appendix B
docs/appendices/hooks.md|`.claude/hooks/bash-guard.sh`|-|plugin/scripts/bash-guard.sh|whole|-|Appendix C bash-guard
docs/appendices/hooks.md|`.claude/hooks/git-guard.sh`|-|plugin/scripts/git-guard.sh|whole|drop_optout|Appendix C git-guard
docs/appendices/skeletons.md|## Appendix D|-|plugin/skills/scaffold/templates/plans-README.md|Skeleton:|-|Appendix D
docs/appendices/skeletons.md|## Appendix E|-|plugin/skills/scaffold/templates/definition-of-done.md|whole|-|Appendix E
docs/appendices/skeletons.md|## Appendix F|-|plugin/skills/scaffold/templates/backlog.md|whole|-|Appendix F
docs/appendices/skeletons.md|## Appendix G|-|plugin/skills/scaffold/templates/design-README.md|Skeleton:|-|Appendix G
docs/appendices/skeletons.md|## Appendix H|head_unreleased|plugin/skills/scaffold/templates/CHANGELOG.md|whole|-|Appendix H
docs/appendices/skills-and-commands.md|`.claude/commands/plan.md`|-|plugin/skills/plan/SKILL.md|whole|drop_skill_keys|Appendix J
docs/appendices/skills-and-commands.md|`.claude/commands/accept.md`|-|plugin/skills/accept/SKILL.md|whole|drop_skill_keys|Appendix K
docs/appendices/skills-and-commands.md|`.claude/commands/retro.md`|-|plugin/skills/retro/SKILL.md|whole|drop_skill_keys|Appendix L
docs/appendices/skills-and-commands.md|`.claude/commands/release.md`|-|plugin/skills/release/SKILL.md|whole|drop_skill_keys|Appendix M
docs/appendices/skills-and-commands.md|`.claude/commands/wrap.md`|-|plugin/skills/wrap/SKILL.md|whole|drop_skill_keys|Appendix N
templates/CLAUDE.template.md|whole|-|plugin/skills/scaffold/templates/CLAUDE.md|whole|-|CLAUDE template
PAIRS
  for sk in "$ROOT"/plugin/skills/*/SKILL.md; do  # every plugin skill, frontmatter only
    [ -f "$sk" ] || continue
    awk 'NR == 1 && /^---$/ { fm = 1; next } fm && /^---$/ { exit } fm && /^disable-model-invocation: true$/ { found = 1 }
      END { exit !found }' "$sk" ||
      e_out="${e_out}  drift: ${sk#"$ROOT"/} lacks disable-model-invocation: true in its frontmatter\n"
  done
}
e_findings=""
case "$REL" in
  docs/appendices/*|plugin/*|templates/CLAUDE.template.md)
    if [ -d "$ROOT/plugin" ]; then check_e; e_findings=$e_out; fi ;;
esac
case "$REL" in
  plugin/*)                      # only Check E applies to plugin files
    if [ -n "$e_findings" ]; then
      { echo "docs-consistency: appendix–plugin drift after editing ${REL}:"; printf '%b' "$e_findings"; } >&2
      exit 2
    fi
    exit 0 ;;
esac

# --- Scope gate (case globs match across '/', so docs/* spans subdirectories) ---
case "$REL" in
  *.md) ;;                       # Markdown only
  *)    exit 0 ;;
esac
# Skip anything git ignores (local-only working notes live outside version
# control), keyed off git-ignore status rather than a hardcoded path. Fail open
# to the normal scope gate if git is absent or cannot answer — never block.
if command -v git >/dev/null 2>&1; then
  git -C "$ROOT" check-ignore -q -- "$REL" 2>/dev/null && exit 0
fi
case "$REL" in
  docs/plans/*) exit 0 ;;        # plans/meta-docs legitimately discuss refs that don't resolve yet
esac
case "$REL" in
  docs/*|README.md|CHANGELOG.md|templates/*) ;;
  *) exit 0 ;;
esac

findings="$e_findings"

# --- Check A: §N / Appendix-X cross-references resolve to real headings ---
# Sections are defined in methodology.md; appendices live in docs/appendices/*.md.
# Each source is optional: if it can't be read, that half of the check is skipped
# (fail-open) rather than flagging every reference.
METH="$ROOT/docs/methodology.md"
APPENDIX_DIR="$ROOT/docs/appendices"

valid_sections=""
[ -r "$METH" ] && valid_sections=$(grep -oE '^## [0-9]+\.' "$METH" | grep -oE '[0-9]+' | sort -un)

valid_appendices=""
[ -d "$APPENDIX_DIR" ] && valid_appendices=$(grep -hoE '^## Appendix [A-Z]' "$APPENDIX_DIR"/*.md 2>/dev/null | grep -oE '[A-Z]$' | sort -u)

if [ -n "$valid_sections" ]; then
  for n in $(grep -oE '§[0-9]+' "$FILE" | grep -oE '[0-9]+' | sort -un); do
    if ! printf '%s\n' $valid_sections | grep -qx "$n"; then
      lines=$(grep -nE "§${n}([^0-9]|$)" "$FILE" | cut -d: -f1 | paste -sd ',' -)
      findings="${findings}  dangling reference §${n} — no such section (line ${lines})\n"
    fi
  done
fi

if [ -n "$valid_appendices" ]; then
  for L in $(grep -oE 'Appendix [A-Z]' "$FILE" | grep -oE '[A-Z]$' | sort -u); do
    if ! printf '%s\n' $valid_appendices | grep -qx "$L"; then
      lines=$(grep -nE "Appendix ${L}([^A-Z]|$)" "$FILE" | cut -d: -f1 | paste -sd ',' -)
      findings="${findings}  dangling reference Appendix ${L} — no such appendix (line ${lines})\n"
    fi
  done
fi

# --- Check B: US spellings (curated, unambiguous; exact-word match) ---
US='color|colors|behavior|behaviors|behavioral|center|centers|centered|organize|organizes|organized|organizing|organization|organizations|recognize|recognizes|recognized|recognizing|prioritize|prioritizes|prioritized|prioritization|summarize|summarizes|summarized|optimize|optimizes|optimized|optimization|standardize|standardized|specialize|specialized|normalize|normalized|analyze|analyzes|analyzed|customize|customized|customization|catalog|catalogs|favor|favors|honor|honors|labor|neighbor|neighbors|fulfill|fulfills|fulfillment|gray|artifact|artifacts|modeling|traveled|traveling|canceled|defense|offense'
us_hits=$(grep -noiE "\b(${US})\b" "$FILE" 2>/dev/null || true)
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  ln="${hit%%:*}"
  word="${hit#*:}"
  findings="${findings}  US spelling '${word}' — use British English (line ${ln})\n"
done <<EOF
$us_hits
EOF

# --- Check C: intra-repo markdown links resolve to existing files ---
# Inline [text](path) / ![alt](path) whose target is a relative path must point at a
# file or directory that exists, resolved against the edited file's directory. Fenced
# code blocks are blanked first (line numbers preserved) so example links inside them
# aren't flagged — this is what lets the docs narrate dangling-link samples safely.
DIR=$(dirname "$FILE")
stripped=$(awk '/^[[:space:]]*```/ { f = !f; print ""; next } { if (f) print ""; else print }' "$FILE")
c_hits=$(printf '%s\n' "$stripped" | grep -noE '\]\([^)]*\)' 2>/dev/null || true)
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  ln=${hit%%:*}
  target=${hit#*:}
  target=${target#"]("}          # strip leading ](
  target=${target%")"}           # strip trailing )
  target=${target%% *}           # drop any "title"
  target=${target%%#*}           # drop #fragment
  [ -n "$target" ] || continue
  case "$target" in
    /*|//*) continue ;;          # absolute / protocol-relative — out of scope
    *:*)    continue ;;          # any scheme (http:, mailto:, ...); colons don't occur in repo paths
  esac
  [ -e "$DIR/$target" ] || findings="${findings}  broken link '${target}' — no such file (line ${ln})\n"
done <<EOF
$c_hits
EOF

# --- Check D: dates are ISO YYYY-MM-DD, not British DD/MM/YYYY ---
# The repo migrated from DD/MM/YYYY to ISO; a dd/mm/yyyy date in an in-scope file
# is a regression. $stripped (from Check C) already blanks fenced code blocks, so
# an illustrative DD/MM/YYYY inside a fence is not flagged. The pattern is
# digits-only, so the literal "DD/MM/YYYY" format token (letters) never matches.
d_hits=$(printf '%s\n' "$stripped" | grep -noE '[0-9]{2}/[0-9]{2}/[0-9]{4}' 2>/dev/null || true)
while IFS= read -r hit; do
  [ -n "$hit" ] || continue
  ln=${hit%%:*}
  date=${hit#*:}
  findings="${findings}  British date '${date}' — use ISO YYYY-MM-DD (line ${ln})\n"
done <<EOF
$d_hits
EOF

if [ -n "$findings" ]; then
  {
    echo "docs-consistency: issues in ${REL}:"
    printf '%b' "$findings"
    echo "Fix these, or proceed if a flag is a false positive. § refs must resolve to methodology.md sections, Appendix refs to docs/appendices/ headings, and [text](path) links to existing files; prose is British English; dates are ISO YYYY-MM-DD; appendix copies match the plugin files they ship as."
  } >&2
  exit 2
fi
exit 0
