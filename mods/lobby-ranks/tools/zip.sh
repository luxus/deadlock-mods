#!/bin/sh
# Build build/deadlock-lobby-ranks-<VERSION>.zip: both paks in load order,
# pak01 the list layout and script, pak02 the entry hook. The zip is what
# the catalog ships; run tools/build.sh first.
set -e
cd "$(dirname "$0")/.."
VER=$(sed -n "s/^const VERSION = '\([^']*\)';/\1/p" src/main.js | head -n 1)
[ -n "$VER" ] || { echo "no VERSION in src/main.js." >&2; exit 1; }
[ -f build/deadlock-lobby-ranks.vpk ] || { echo "build/deadlock-lobby-ranks.vpk is missing. Run tools/build.sh first." >&2; exit 1; }
[ -f build/deadlock-lobby-ranks-entry-hook.vpk ] || { echo "build/deadlock-lobby-ranks-entry-hook.vpk is missing. Run tools/build.sh first." >&2; exit 1; }
rm -f build/deadlock-lobby-ranks-$VER.zip
(
	cd build
	cp deadlock-lobby-ranks.vpk pak01_dir.vpk
	cp deadlock-lobby-ranks-entry-hook.vpk pak02_dir.vpk
	python3 - "$VER" <<'PY'
import sys, zipfile
ver = sys.argv[1]
with zipfile.ZipFile(f'deadlock-lobby-ranks-{ver}.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    for n in ('pak01_dir.vpk', 'pak02_dir.vpk'):
        info = zipfile.ZipInfo(n, date_time=(2026, 1, 1, 0, 0, 0))
        info.compress_type = zipfile.ZIP_DEFLATED
        info.external_attr = 0o644 << 16
        with open(n, 'rb') as f:
            z.writestr(info, f.read())
PY
	rm pak01_dir.vpk pak02_dir.vpk
)
sha256sum build/deadlock-lobby-ranks-$VER.zip
