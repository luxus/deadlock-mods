# Rules

A comment does not enforce a rule. The check named here does.

## The catalog

| Mistake | Check |
| --- | --- |
| A listing is edited by hand, so version, hash or size drift from the artifact | `tools/update-listing.js` is the only writer; `sh tools/check-catalog.sh` in CI |
| A file in `site/files/` is not referenced, or two listings reference one file | `sh tools/check-catalog.sh` |
| A listing in `site/listings/` has no `catalog.json` entry | `sh tools/check-catalog.sh` |
| A DMM client rejects the source (descriptor, catalog, paths, sizes, hashes) | `node tools/dmm-check.mjs site`, DMM's own preflight, vendored at `tools/dmm-check.mjs` |
| A mod's listing ships a version its `CHANGELOG.md` has no section for | `sh tools/check-catalog.sh` |
| A mod's changelog is not published to the site, or the published copy is stale | `sh tools/check-catalog.sh`; `tools/release.sh` copies `mods/<id>/CHANGELOG.md` to `site/changelogs/<id>.md` |
| The Improved Quickbuy listing is not the stored `release/` VPK | `sh tools/check-catalog.sh` |
| The showcase and the DMM source disagree (page edited separately) | There is nothing to edit: `site/index.html` renders `catalog.json` and `site/listings/*.json` |
| A release changes the artifact but not the listing, or the other way round | `tools/release.sh` writes both in one commit |
| A superseded artifact stays in `site/files/` after a release replaces it | `tools/release.sh` prunes files no listing references; `sh tools/check-catalog.sh` |

## The mods and the library

| Mistake | Check |
| --- | --- |
| A rebuilt pak does not match `mods/SHA256SUMS` (a different modlock changes the sha) | `sh tools/ci.sh`, modlock pinned to v0.1.77 |
| `addon_settings.js` exists anywhere but `lib/addon-settings/` (a per-mod copy is how lobby-ranks PR #3 shipped a wrong-build pak and zipline-boost shipped BUILD 10 beside BUILD 9 copies) | `sh tools/check-one-addon-settings.sh` |
| A mod has no `tools/assemble.sh`, `tools/build.sh` or `test/test.js` | `sh tools/ci.sh` |
| A mod README does not state the script VERSION or says Not released | `sh tools/check-readme.sh` |
| A pak source contains a credential | `python3 tools/check-secrets.py` |
| Two mods ship the same pak path (the lower pak number wins and the other never loads; two paks of one mod may) | `python3 tools/check-overlap.py` |
| An overridden Valve layout loses a native panel id or snippet name | each mod's `test/native_ids.py` (via `sh tools/ci.sh`) |
| A cleanroom acceptance item (C1-C29, P1-P38) is not covered, or cites a line that moved | `python3 tools/check-trace.py` |
| `step()` does not call `syncPlay()`, so `#HudppPlay` keeps the margin `liftPins` saw | `sh tools/check-play-pin.sh` (TLA+), and `node tools/guard-play-pin.js` in improved-quickbuy |
| A click on the parked HUD++ tab, while our tab is up, does not run HUD++ `showTab` | `sh tools/check-hudpp-tabs.sh` (TLA+) |
| The ADDONS list is under 880px, or taller than the host's share of the 972px Esc parent | `node tools/guard-look-height.js` (improved-quickbuy) |
| An inline `fontFamily` names a `@define` instead of a stack | `node tools/guard-inline-font.js` (improved-quickbuy) |
| The master tooltip is not anchored on the switch or the title block | `node tools/guard-tooltip-anchor.js` (improved-quickbuy) |
| `HEAD` does not contain `origin/main` | `node tools/guard-branch-base.js` (improved-quickbuy) |
| A mod's mutant survives (a test that cannot fail proves nothing) | each mod's `test/mutants.sh` (via `sh tools/ci.sh`) |
| An Improved Quickbuy release VPK does not match its stored digest | `sh tools/ci.sh` verifies every `release/` pair |

CI (`ci.yml`) runs `sh tools/ci.sh` and `sh tools/check-catalog.sh` on every
push. GitHub Pages deploys `site/` (`pages.yml`); a `<mod-id>-v<version>` tag
publishes the GitHub release (`release.yml`).
