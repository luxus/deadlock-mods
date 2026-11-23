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
| [Improved Quickbuy](https://github.com/luxus/improved-quickbuy) 1.0.4 | available (GitHub Release asset) |
| [Deadlock Commend](https://github.com/luxus/deadlock-qol-mods/tree/main/paks/commend) 2.0.0 | available (GitHub Release asset) |
| [Deadlock Profile Links](https://github.com/luxus/deadlock-qol-mods/tree/main/paks/profile-links) 2.0.0 | available (GitHub Release asset) |
| [Deadlock Lobby Ranks](https://github.com/luxus/deadlock-qol-mods/tree/main/paks/lobby-ranks) 0.2.1 | available (GitHub Release asset: zip with both paks) |
| [Deadlock Zipline Boost](https://github.com/luxus/deadlock-qol-mods/tree/main/paks/zipline-boost) 0.1.0 | available (GitHub Release asset) |
| [Thicker Outlines (Vulkan)](https://deadlockconfig.com/) 1.0 (HoppCX; third-party) | available (GitHub Release asset) |

The VPKs are the GitHub Release assets of each mod. Thicker Outlines (Vulkan) is a third-party CompLock part by HoppCX, redistributed unchanged because the Pack Builder no longer lists it.

The earlier Improved Quickbuy-only source at `https://luxus.github.io/improved-quickbuy/dmm-source.json` stays as it is. It uses the same `sourceId` (`luxus`) on the same origin (`https://luxus.github.io`). Adding both sources in DMM can clash; prefer this catalog going forward if you want every luxus listing in one place.

## Layout

- `dmm-source.json` — source descriptor (`protocolVersion` 1.0, `sourceId` luxus)
- `catalog.json` — index
- `mods/*.json` — listing details
- GitHub Pages serves the repository root from the `main` branch

## License

MIT for the catalog files in this repository. Each mod keeps its own license. Valve's game files are not covered.
