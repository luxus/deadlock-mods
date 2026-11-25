#!/bin/sh
# The catalog is derived data: listings point at files, files decide hashes.
# DMM's preflight plus the invariants it does not check. Run by CI on every push.
set -e
cd "$(dirname "$0")/.."

echo "== DMM offline preflight =="
node tools/dmm-check.mjs site

echo "== every listing and file is catalogued =="
node -e '
const fs = require("fs");
const catalog = JSON.parse(fs.readFileSync("site/catalog.json", "utf8"));
const ids = new Set(catalog.items.map(i => i.id));
const onDisk = {};
for (const f of fs.readdirSync("site/listings").filter(f => f.endsWith(".json"))) {
  const d = JSON.parse(fs.readFileSync("site/listings/" + f, "utf8"));
  onDisk[d.id] = d;
}
const unlisted = Object.keys(onDisk).filter(id => !ids.has(id));
if (unlisted.length) { console.error("site/listings has no catalog entry:", unlisted); process.exit(1); }
const referenced = [];
for (const id of ids) {
  for (const a of onDisk[id].release.artifacts) referenced.push(a.filename);
}
const files = fs.readdirSync("site/files");
const orphans = files.filter(f => !referenced.includes(f));
if (orphans.length) { console.error("site/files is not referenced by a listing:", orphans); process.exit(1); }
if (new Set(referenced).size !== referenced.length) { console.error("two listings reference the same file"); process.exit(1); }
console.log("catalog:", ids.size, "listings,", files.length, "files");
'

echo "== every mod's listing follows its CHANGELOG =="
node -e '
const fs = require("fs");
for (const id of fs.readdirSync("mods").filter(n => fs.statSync("mods/" + n).isDirectory())) {
  const p = "site/listings/" + id + ".json";
  if (!fs.existsSync(p)) continue;
  const v = JSON.parse(fs.readFileSync(p, "utf8")).release.version;
  const log = "mods/" + id + "/CHANGELOG.md";
  if (!fs.existsSync(log)) { console.error(log + " is missing"); process.exit(1); }
  if (!fs.readFileSync(log, "utf8").includes("## [" + v + "] - ")) {
    console.error(log + " has no section for " + v + ", which the catalog ships"); process.exit(1);
  }
  console.log(id, v, "follows its CHANGELOG.md");
}
'

echo "== every mod's changelog is published to the site =="
node -e '
const fs = require("fs");
for (const id of fs.readdirSync("mods").filter(n => fs.statSync("mods/" + n).isDirectory())) {
  const p = "site/listings/" + id + ".json";
  if (!fs.existsSync(p)) continue;
  const v = JSON.parse(fs.readFileSync(p, "utf8")).release.version;
  const pub = "site/changelogs/" + id + ".md";
  if (!fs.existsSync(pub)) { console.error(pub + " is missing (tools/release.sh writes it)"); process.exit(1); }
  if (!fs.readFileSync(pub, "utf8").includes("## [" + v + "] - ")) {
    console.error(pub + " has no section for " + v + ", which the catalog ships"); process.exit(1);
  }
}
console.log("changelogs published for every mod with a listing");
'

echo "== quickbuy listing follows its release store =="
node -e '
const fs = require("fs");
const listing = JSON.parse(fs.readFileSync("site/listings/improved-quickbuy.json", "utf8")).release;
const v = listing.version;
const stored = fs.readFileSync("mods/improved-quickbuy/release/improved-quickbuy-" + v + ".vpk.sha256", "utf8").split(" ")[0];
if (stored !== listing.artifacts[0].hashes.sha256) {
  console.error("catalog quickbuy", v, "is not the stored release artifact:", listing.artifacts[0].hashes.sha256, "vs", stored); process.exit(1);
}
console.log("quickbuy", v, "matches its release store");
'
