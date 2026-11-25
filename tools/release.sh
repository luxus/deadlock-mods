#!/bin/sh
# usage: sh tools/release.sh <mod-id> <version> [artifact]
#
#   sh tools/release.sh deadlock-commend 2.0.1 mods/deadlock-commend/build/deadlock-commend.vpk
#   sh tools/release.sh lobby-ranks 0.2.2 mods/lobby-ranks/build/deadlock-lobby-ranks-0.2.2.zip
#   sh tools/release.sh improved-quickbuy 1.0.5
#
# A release is one commit: the artifact lands in site/files/, the listing is
# rewritten from the artifact's real bytes, and the catalog snapshotId bumps.
# The mod's CHANGELOG.md must already have the [version] section (Improved
# Quickbuy writes its with tools/changelog.sh; the others are hand-written).
# improved-quickbuy takes its artifact from its release/ store (base64 and
# sha256); every other mod takes the artifact you built: sh tools/ci.sh, and
# lobby-ranks also mods/lobby-ranks/tools/zip.sh. Push, then tag
# <mod-id>-v<version>; the release workflow cuts the GitHub release from it.
set -e
cd "$(dirname "$0")/.."
ROOT=$(pwd)
[ $# -ge 2 ] || { echo "usage: sh tools/release.sh <mod-id> <version> [artifact]" >&2; exit 1; }
MOD=$1
V=$2
M=mods/$MOD
[ -f "$M/CHANGELOG.md" ] || { echo "$M has no CHANGELOG.md." >&2; exit 1; }
grep -q "^## \[$V\] - " "$M/CHANGELOG.md" || { echo "$M/CHANGELOG.md has no [$V] section. Write it first." >&2; exit 1; }
if [ "$MOD" = improved-quickbuy ]; then
	B=$M/release/improved-quickbuy-$V.vpk.b64
	[ -f "$B" ] || { echo "missing $B. Build the VPK and store it (CONTRIBUTING.md) first." >&2; exit 1; }
	D=$(mktemp -d)
	base64 -d "$B" > "$D/improved-quickbuy-$V.vpk"
	(cd "$D" && sha256sum -c "$ROOT/$B.sha256")
	ARTIFACT=$D/improved-quickbuy-$V.vpk
else
	[ $# -eq 3 ] || { echo "usage: sh tools/release.sh $MOD $V <artifact>" >&2; exit 1; }
	ARTIFACT=$3
	[ -f "$ARTIFACT" ] || { echo "no artifact at $ARTIFACT. sh tools/ci.sh builds every mod." >&2; exit 1; }
fi
node tools/update-listing.js "$MOD" "$V" "$ARTIFACT"
git add -A
git commit -m "release: $MOD $V"
echo "push, then tag: git tag $MOD-v$V && git push origin $MOD-v$V"
