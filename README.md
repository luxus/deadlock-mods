# luxus Deadlock Mods

A static [Deadlock Mod Manager](https://deadlockmods.app/) source for luxus's Deadlock addons. Other people may add it; it is mainly for these mods.

**Source URL** (DMM → Settings → Mods → Mod sources → Add source):

```
https://luxus.github.io/deadlock-mods/dmm-source.json
```

Or use the "Add to DMM" button on the [catalog page](https://luxus.github.io/deadlock-mods/).

## Listings

| Mod | Status |
| --- | --- |
| [Improved Quickbuy](https://github.com/luxus/improved-quickbuy) 1.0.2 | available (GitHub Release asset) |
| [Deadlock Commend](https://github.com/luxus/deadlock-commend) | unavailable (test build only, no release) |

The Improved Quickbuy 1.0.2 VPK is the existing release asset. Deadlock Commend has no artifact in this catalog.

The earlier Improved Quickbuy-only source at `https://luxus.github.io/improved-quickbuy/dmm-source.json` stays as it is. It uses the same `sourceId` (`luxus`) on the same origin (`https://luxus.github.io`). Adding both sources in DMM can clash; prefer this catalog going forward if you want every luxus listing in one place.

## Layout

- `dmm-source.json` — source descriptor (`protocolVersion` 1.0, `sourceId` luxus)
- `catalog.json` — index
- `mods/*.json` — listing details
- GitHub Pages serves the repository root from the `main` branch

## License

MIT for the catalog files in this repository. Each mod keeps its own license. Valve's game files are not covered.
