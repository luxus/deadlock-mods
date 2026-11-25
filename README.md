# luxus Deadlock Mods

One repository: the mods, the settings library they share, the toolchain that
builds and releases them, and the catalog that ships them. The registry, the
showcase page and the mods read one set of data, so they cannot drift apart.

**Source URL** (DMM → Settings → Mods → Mod sources → Add source):

```
https://luxus.github.io/deadlock-mods/dmm-source.json
```

Or use the "Add to DMM" button on the [catalog page](https://luxus.github.io/deadlock-mods/),
which renders the same `catalog.json` and `site/listings/*.json` the source serves.
**Shiv** reads the same URL: open its Sources screen, paste it, confirm.

## Mods

| Mod | Directory | Released |
| --- | --- | --- |
| Improved Quickbuy | `mods/improved-quickbuy/` | 1.0.4 |
| Deadlock Commend | `mods/deadlock-commend/` | 2.0.0 |
| Deadlock Profile Links | `mods/deadlock-profile-links/` | 2.0.3 |
| Deadlock Lobby Ranks | `mods/deadlock-lobby-ranks/` | 0.2.1 (zip of both paks) |
| Deadlock Zipline Boost | `mods/deadlock-zipline-boost/` | 0.1.0 |
| Thicker Outlines (Vulkan) | third-party, VPK only, anonymous | 1.0 |
| Thicker Outlines (DX11) | third-party, VPK only, anonymous | 1.0 |
| No Music, Low Gun Volume | third-party, VPK only, anonymous | 1.0 |

Every mod follows the same shape; `mods/improved-quickbuy` is the guideline:
`src/`, `vanilla/`, `test/`, `tools/assemble.sh`, `tools/build.sh`, a README
that states the script VERSION, and a `CHANGELOG.md` the release takes its
notes from.

## Layout

- `site/` — what GitHub Pages serves: `dmm-source.json`, `catalog.json`,
  `listings/*.json`, `history/*.json` (the release-history documents DMM and
  Shiv read, generated from the mods' CHANGELOGs), `files/` (the VPKs and zips
  themselves; relative download URLs, so the source is self-contained),
  `images/` (the screenshots the listings point at; svg placeholders until
  real ones land), `index.html` (the showcase) and `party/` (the Lobby
  Ranks party bridge page).
- `mods/` — the mods as peers; `mods/SHA256SUMS` records what each pak
  rebuilds to (modlock v0.1.77).
- `lib/` — `addon-settings/`, the one copy of the settings-menu library every
  mod vendors (`vendor.sh`), its example (`examples/hello-addon/`), and
  `steam-id.js`.
- `tools/` — the one toolchain: `ci.sh` (build, test, mutants, the TLA+
  gates, the source checks, the shas), `check-catalog.sh` (the catalog gates),
  `release.sh`, `update-listing.js`, `loc.js`, `native_ids.py`, `formal/`
  (TLA+ models of the library's tab hook and PLAY pin).
- `docs/` — `ADDON-SETTINGS-API.md` (the library) and `cleanroom-spec/` (the
  Commend and Profile Links acceptance specs, machine-checked by
  `tools/check-trace.py`).

## Build and test

```sh
curl -fsSL -o tools/modlock https://github.com/paralin/modlock/releases/download/v0.1.77/modlock-linux-amd64 && chmod +x tools/modlock
sh tools/ci.sh              # every mod: guards, build, tests, mutants; then the source checks and shas
sh tools/check-catalog.sh   # the catalog gates (no modlock needed)
```

## Releasing

A release is one commit and one tag:

```sh
# write the [X.Y.Z] section in the mod's CHANGELOG.md first
# (improved-quickbuy: sh mods/improved-quickbuy/tools/changelog.sh release X.Y.Z)
sh tools/ci.sh
sh tools/release.sh deadlock-commend 2.0.2 mods/deadlock-commend/build/deadlock-commend.vpk
# deadlock-lobby-ranks: sh mods/deadlock-lobby-ranks/tools/zip.sh first and pass the zip
git push origin main
git tag deadlock-commend-v2.0.1 && git push origin deadlock-commend-v2.0.1
```

`tools/release.sh` copies the artifact into `site/files/`, rewrites the
listing from the artifact's real bytes, regenerates the release-history
document from the mod's `CHANGELOG.md` (`tools/history.js`), and bumps the
catalog `snapshotId`; Pages deploys `site/` on push, and the tag workflow
publishes the GitHub release with the changelog section as notes. Nobody
edits a listing by hand. A mod's screenshots are the `images` field of its
listing — drop the real file in `site/images/` and put it first in the
array; the shipped svg placeholder stays as a fallback.

Third-party entries have no source: add the listing, the artifact in
`site/files/`, a placeholder image, and tag `<id>-v<version>`; the release
workflow then publishes them with the listing description as notes.

## CI

`ci.yml` runs `tools/ci.sh` (mods) and `tools/check-catalog.sh` (catalog) on
every push; `release.yml` turns a `<mod-id>-v<version>` tag into a GitHub
release. The catalog gates: DMM's own offline preflight (`tools/dmm-check.mjs`,
vendored), every listing catalogued, every file referenced by exactly one
listing, every mod's listing following its `CHANGELOG.md`, and Improved
Quickbuy's listing matching its stored release VPK.

## Before this repository

The mods lived in [deadlock-qol-mods](https://github.com/luxus/deadlock-qol-mods)
and [improved-quickbuy](https://github.com/luxus/improved-quickbuy); both are
frozen. The Improved Quickbuy-only source at
`https://luxus.github.io/improved-quickbuy/dmm-source.json` still serves its
last state until that repository is archived.

## License

MIT (LICENSE) for the repository's own files; credits and third-party notices
in NOTICE. Valve's game files are not covered.
