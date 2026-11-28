# Deadlock Lobby Ranks

0.2.3. Rank badges and party markers on the Escape menu player list.

Clean-room, MIT (LICENSE).

## What it does

The main VPK patches `players_list.xml` (current game, decompiled from lea `pak01_dir.vpk` after the 18 November 2026 update) so the list loads `lobby_ranks.js`. On the first Escape menu open in a match, the script switches to `#PlayersTab`, walks `#TeamEntries`, probes each player's profile card once via fast native lookups (aborting and dismissing immediately if Esc is closed or on Hideout entry), caches the roster for the match, and puts a 72x47 px `Image` (`LrBadge`) plus optional 22x22 px party icons (`LrParty`) in `#MainContents`. The image URL is:

`https://api.deadlock-api.com/v1/players/{id}/rank/image?format=webp`

Account ids are read from panel attributes, `$.Localize` `{i:r:account_id}` / `{i:account_id}`, and the profile card `#AccountID` label. SteamID3 and Steam64 values are converted.

A CompLock / ADDONS tab **Lobby Ranks** has toggles for rank badges and party markers, both on by default.

## Two VPKs

| File | What it contains |
|---|---|
| `build/deadlock-lobby-ranks.vpk` | List layout, script, CSS, loc. **Install this first.** |
| `build/deadlock-lobby-ranks-entry-hook.vpk` | Optional override of `players_list_entry.xml` with hidden `{g:citadel_hero_name:hero_id}` row key label, plus CSS. No script. |

Vanilla list entries only bind `{s:player_name}`. If the main pack alone has duplicate-hero or swap-row ambiguity, also install the hook pack (game closed).

## Build

```sh
sh tools/assemble.sh
node test/test.js
node test/files.js
sh test/mutants.sh
sh tools/build.sh
```

`modlock` defaults to `/workspace/qol-extract/tools/modlock`. Override with `MODLOCK=…`.
