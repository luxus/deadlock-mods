# Changelog

All notable changes to Deadlock Lobby Ranks are documented here. A release takes its
notes from its section here.

## [Unreleased]

## [0.2.3] - 2026-11-28

### Fixed

- Removed the 8,000-node JS DOM BFS in `findCards()` in favor of fast native `PlayerMenuContents` / `AccountID` lookups, eliminating the Escape-menu lag spike.
- Eliminated repeated popup waves: single-pass probing (`PROBE_TRIES = 1`), zero inter-row delay, automatic `#PlayersTab` activation on first scan, immediate menu dismissal on completion or Esc close, and preserved `tries` across roster updates.
- Reset cached match/party state when entering the Hideout and unload the hidden party-bridge `CitadelHTMLPanel` (`about:blank`) after receiving a result or timing out.
- Updated `site/party/party.js` to also publish the result in `location.hash` for Panorama's `HTMLURLChanged` fallback and aligned `.LrBadge` (72x47 px) and `.LrPartyIcon` (22x22 px, `ignore-parent-flow: true`, `overflow: noclip`) styling.

## [0.2.2] - 2026-11-25

### Changed

- The vendored Addon Settings library moves from 1.2.3 (`BUILD` 9) to 1.2.6 (`BUILD` 13): the ADDONS
  list grows to 880 px before it scrolls (1.2.4), multi-layout registrations work (1.2.5), and the
  Activated bubble recursion and the alias-unset-on-takeover are fixed (1.2.6).

## [0.2.1] - 2026-11-23

- The mod as it moved into this repository: rank badges next to every player in the Escape menu player
  list, optional party markers, two paks installed together (list + entry hook), a settings tab in
  CompLock HUD++ or the ADDONS window, and localization.
- Earlier history is in the [deadlock-qol-mods repository](https://github.com/luxus/deadlock-qol-mods).
