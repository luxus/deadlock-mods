#!/usr/bin/env node
// usage: node tools/history.js <id> [--seed <version>=<sha16>]
//
// Regenerates site/history/<id>.json from mods/<id>/CHANGELOG.md: one release
// item per "## [x.y.z] - date" section, newest first, with the section body
// as the changelog text. A release's contentRevision resolves from the current
// listing (the shipped release), from Improved Quickbuy's release/ digests, or
// from the previously published history file; --seed covers a version that
// predates the repository (record it once, it carries forward afterwards).
// tools/release.sh runs this on every release: CHANGELOG.md stays the one
// changelog source, and the served history never disagrees with it.
const fs = require("fs");

const args = process.argv.slice(2);
const id = args[0];
if (!id || !fs.existsSync("mods/" + id + "/CHANGELOG.md")) {
  console.error("usage: node tools/history.js <id> [--seed <version>=<sha16>]");
  process.exit(1);
}

const known = new Map();
const listing = JSON.parse(fs.readFileSync("site/listings/" + id + ".json", "utf8"));
if (listing.release) {
  known.set(listing.release.version, listing.release.contentRevision.replace(/^sha256-/, ""));
}
const pub = "site/history/" + id + ".json";
if (fs.existsSync(pub)) {
  for (const item of JSON.parse(fs.readFileSync(pub, "utf8")).items) {
    known.set(item.version, item.contentRevision.replace(/^sha256-/, ""));
  }
}
for (const f of fs.readdirSync("mods/improved-quickbuy/release")) {
  const m = f.match(/^improved-quickbuy-(\d+\.\d+\.\d+)\.vpk\.sha256$/);
  if (m) {
    known.set(m[1], fs.readFileSync("mods/improved-quickbuy/release/" + f, "utf8").split(" ")[0].slice(0, 16));
  }
}
for (let i = 1; i < args.length; i += 1) {
  if (args[i] !== "--seed" || !args[i + 1]) continue;
  const [v, rev] = args[i + 1].split("=");
  if (!rev) { console.error("--seed wants <version>=<sha16>"); process.exit(1); }
  known.set(v, rev);
}

const lines = fs.readFileSync("mods/" + id + "/CHANGELOG.md", "utf8").split("\n");
const section = /^## \[(\d+\.\d+\.\d+)\] - (\d{4}-\d{2}-\d{2})$/;
const items = [];
let cur = null;
for (const line of lines) {
  const m = line.match(section);
  if (m) {
    if (cur) items.push(cur);
    cur = { version: m[1], date: m[2], body: [] };
    continue;
  }
  if (/^## /.test(line)) { if (cur) { items.push(cur); cur = null; } continue; }
  if (cur && !/^\[.*\]: /.test(line)) cur.body.push(line);
}
if (cur) items.push(cur);

const out = [];
for (const s of items) {
  const rev = known.get(s.version);
  if (!rev) {
    console.error("no contentRevision for " + id + " " + s.version + "; run with --seed " + s.version + "=<sha16>");
    process.exit(1);
  }
  const body = s.body.join("\n").replace(/^\n+|\n+$/g, "");
  out.push({ id: s.version, contentRevision: "sha256-" + rev, version: s.version, publishedAt: s.date, changelog: body });
}
fs.writeFileSync(pub, JSON.stringify({ items: out, nextCursor: null }, null, 2) + "\n");
console.log(id + ": " + out.length + " releases -> " + pub);
