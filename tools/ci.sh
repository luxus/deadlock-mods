#!/bin/sh
# One pipeline for every mod: guards, assemble, compile, tests, mutants — plus the
# shared-library gates (one copy of addon_settings.js, the TLA+ models), the source
# checks, the rebuild shas, and Improved Quickbuy's release-store digests.
# CI runs this on every push; sh tools/ci.sh is also the local build.
set -eu
cd "$(dirname "$0")/.."
ROOT=$PWD
MODLOCK=${MODLOCK:-$ROOT/tools/modlock}

git fetch origin main --quiet 2>/dev/null || true	# guard-branch-base reads origin/main

if [ ! -x "$MODLOCK" ]; then
	echo "modlock is missing at $MODLOCK." >&2
	echo "Install v0.1.77: curl -fsSL -o tools/modlock https://github.com/paralin/modlock/releases/download/v0.1.77/modlock-linux-amd64 && chmod +x tools/modlock" >&2
	exit 1
fi
ver=$("$MODLOCK" --version 2>/dev/null | awk '{print $NF}')
if [ "$ver" != "v0.1.77" ]; then
	echo "modlock is $ver. Install v0.1.77 from https://github.com/paralin/modlock/releases/download/v0.1.77/modlock-linux-amd64" >&2
	echo "A different modlock changes the pak sha. mods/SHA256SUMS was recorded with v0.1.77." >&2
	exit 1
fi
export MODLOCK

sh tools/check-one-addon-settings.sh
echo "== hudpp tabs =="
sh tools/check-hudpp-tabs.sh
echo "== play pin =="
sh tools/check-play-pin.sh

for dir in mods/*/; do
	name=${dir#mods/}
	name=${name%/}
	if [ ! -f "$dir/tools/assemble.sh" ] || [ ! -f "$dir/tools/build.sh" ]; then
		echo "$name has no tools/assemble.sh and tools/build.sh." >&2
		echo "Every mod builds the same way. sh tools/ci.sh is the build." >&2
		exit 1
	fi
	if [ ! -f "$dir/test/test.js" ]; then
		echo "$name has no test/test.js." >&2
		echo "Every mod ships tests. mods/improved-quickbuy is the shape." >&2
		exit 1
	fi
	echo "== guards $name =="
	(cd "$dir" && for f in tools/guard-*.js; do [ -e "$f" ] || continue; echo "-- $f"; node "$f" || exit 1; done)
	echo "== build $name =="
	(cd "$dir" && sh tools/build.sh)
	if [ -f "$dir/tools/zip.sh" ]; then
		echo "== zip $name =="
		(cd "$dir" && sh tools/zip.sh)
	fi
	echo "== test $name =="
	(cd "$dir" && node test/test.js)
	if [ -f "$dir/test/files.js" ]; then
		(cd "$dir" && node test/files.js)
	fi
	if [ -f "$dir/test/native_ids.py" ]; then
		(cd "$dir" && python3 test/native_ids.py .)
	fi
	(cd "$dir" && sh test/mutants.sh)
	if [ -f "$dir/test/registry.js" ]; then
		echo "== registry $name =="
		(cd "$dir" && sh ../../lib/addon-settings/examples/hello-addon/build.sh >/dev/null && node test/registry.js)
	fi
	if [ -d "$dir/release" ]; then
		echo "== release store $name =="
		d=$(mktemp -d)
		(cd "$dir" && for f in release/*.vpk.sha256; do
			n=$(basename "$f" .sha256)
			base64 -d "release/$n.b64" > "$d/$n"
		done)
		(cd "$d" && sha256sum -c "$ROOT/$dir"release/*.sha256)
	fi
done

sh tools/check-readme.sh
echo "== trace =="
python3 tools/check-trace.py
echo "== overlap =="
python3 tools/check-overlap.py --self-test
python3 tools/check-overlap.py
echo "== secrets =="
python3 tools/check-secrets.py --self-test
python3 tools/check-secrets.py
echo "== rebuild shas =="
sha256sum -c mods/SHA256SUMS
