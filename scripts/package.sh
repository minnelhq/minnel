#!/bin/sh
# Build Minnel as a zip to upload to claude.ai (Customize > Plugins > Add > Upload plugin).
# Claude Code users don't need it: they install from the marketplace in this repo.
#
# The zip holds what the plugin needs: plugin/ as committed at HEAD (uncommitted edits and
# untracked files stay out) except its test harness (plugin/scripts/tests/), plus LICENSE and
# NOTICE from the repo root, since Apache-2.0 asks for NOTICE to travel with the code. Everyone
# the plugin is shared with receives every file. A symlink in plugin/ stops the build.
#
# scripts/package.sh                    the release in plugin/.claude-plugin/plugin.json
# scripts/package.sh --dev 0.4.0-dev.1  a test build: the same files, with that pre-release
#                                       version in the zip's manifest only
set -eu

usage() { echo "usage: scripts/package.sh [--dev X.Y.Z-PRERELEASE]" >&2; exit 2; }

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

dev=
case $# in
  0) ;;
  2) [ "$1" = --dev ] && [ -n "$2" ] || usage; dev=$2 ;;
  *) usage ;;
esac

for tool in git zip unzip python3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "$tool not found" >&2; exit 2; }
done

if [ -n "$(git status --porcelain -- plugin)" ]; then
  echo "plugin/ has uncommitted changes; packaging HEAD without them" >&2
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
trap 'exit 130' INT TERM HUP
stage=$tmp/plugin
mkdir "$stage"
git archive --format=tar -o "$tmp/plugin.tar" HEAD plugin
tar -x -f "$tmp/plugin.tar" -C "$stage" --strip-components=1
if [ -n "$(find "$stage" -type l)" ]; then
  echo "plugin/ holds a symlink; refusing to package it" >&2
  exit 2
fi
rm -rf "$stage/scripts/tests"
cp LICENSE NOTICE "$stage"

# Prints the version to build: the --dev one (written into the staged manifest) or the
# manifest's own. Either must be plain SemVer, so it is safe in the zip's file name.
version=$(python3 -I - "$stage/.claude-plugin/plugin.json" "$dev" <<'EOF'
import json, re, sys
path, dev = sys.argv[1], sys.argv[2]
with open(path, encoding='utf-8') as f:
    manifest = json.load(f)
core = r'(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)'
if dev:
    if not re.fullmatch(core + r'-[0-9A-Za-z.-]+', dev):
        sys.exit(f'--dev needs a pre-release version, such as 0.4.0-dev.1, not {dev!r}')
    manifest['version'] = dev
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write('\n')
version = manifest.get('version', '')
if not version:
    sys.exit('plugin.json has no version; set one, or build a test zip with --dev,\n'
             'such as: scripts/package.sh --dev 0.4.1-dev.1')
if not re.fullmatch(core + r'(-[0-9A-Za-z.-]+)?', version):
    sys.exit(f'plugin.json version is not SemVer: {version!r}')
print(version)
EOF
)

if command -v claude >/dev/null 2>&1; then
  claude plugin validate "$stage"
elif [ "${SKIP_VALIDATE:-}" = 1 ]; then
  echo "claude CLI not found: building without validation (SKIP_VALIDATE=1)" >&2
else
  echo "claude CLI not found: install it, or set SKIP_VALIDATE=1 to build unvalidated" >&2
  exit 2
fi

out="$root/dist/minnel-$version.zip"
mkdir -p dist
rm -f "$out"
(cd "$stage" && zip -r -X -q "$out" .)
echo "Built $out"
unzip -l "$out"
