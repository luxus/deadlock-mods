# Contributing

## Commits

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<optional scope>): <summary in the imperative, lower case, no period>
```

| Type | Use for | Changelog section |
| --- | --- | --- |
| `feat` | something new a player can see or use | Added |
| `fix` | a bug a player could hit | Fixed |
| `perf` | less work in game, same behavior | Changed |
| `revert` | undoing an earlier change | Removed |
| `refactor` | code changes with no effect in game | not listed |
| `docs` | README, CREDITS, comments | not listed |
| `chore` | build, tools, CI, tests, release housekeeping | not listed |

Scopes are optional; useful ones are `hud`, `shop`, `settings`, `complock`, `dmm`.
A breaking change (for example settings that no longer load) gets a `!` after the type and a
`BREAKING CHANGE:` footer, and means a major version bump. Write the summary for players: it becomes the
changelog line as is.

## Versions

[Semantic Versioning](https://semver.org/spec/v2.0.0.html): `fix`/`perf` only → patch, any `feat` → minor,
any breaking change → major. 1.0.0 is the first release and the changelog baseline; earlier development
history is not in the changelog.

## Making a release

1. `tools/check.sh` is green (tests, mutants, provenance) and the VPK was tried in game.
2. `tools/changelog.sh preview` shows the new section from the commits since the last tag.
3. `tools/changelog.sh release X.Y.Z` writes it into `CHANGELOG.md` as `[X.Y.Z] - <today>`; edit the
   wording if needed.
4. Store the VPK as `release/improved-quickbuy-X.Y.Z.vpk.b64` with its `.sha256`.
5. From the repository root run `sh tools/release.sh improved-quickbuy X.Y.Z`: it verifies the stored VPK against
   its `.sha256`, rewrites `site/listings/improved-quickbuy.json` from the real bytes (`release.id`, `version`,
   `contentRevision`, artifact `filename`, `download.url`, `size`, `hashes.sha256`), bumps the catalog
   `snapshotId` and commits.

CI runs `tools/check-catalog.sh` on every push: DMM's own source checker, and the listing must follow
`CHANGELOG.md` and the stored release VPK. The catalog site deploys from `site/` automatically. Push, then
tag `improved-quickbuy-vX.Y.Z`; the release workflow publishes the GitHub release with the `CHANGELOG.md`
section as its notes (`tools/changelog.sh notes X.Y.Z` prints them for review).

`tools/changelog.sh preview` and `release` need [git-cliff](https://git-cliff.org) (or `npx`); CI does not
use it.
