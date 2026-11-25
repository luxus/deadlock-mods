#!/usr/bin/env node
// usage: node tools/update-listing.js <listing-id> <version> <artifact-file>
// Rewrites the listing's release block from the artifact's real bytes (sha256,
// size, filename, ../files URL), copies the artifact into site/files/ and bumps
// catalog.json's snapshotId to today. The release scripts call this; nobody
// edits a listing by hand.
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const [id, version, artifact] = process.argv.slice(2);
if (!id || !version || !artifact) {
  console.error("usage: node tools/update-listing.js <listing-id> <version> <artifact-file>");
  process.exit(1);
}
const listingPath = path.join("site/listings", id + ".json");
const listing = JSON.parse(fs.readFileSync(listingPath, "utf8"));
const old = listing.release.version;
const oldName = listing.release.artifacts[0].filename;
const filename = oldName.replace(old, version);
if (old !== version && filename === oldName) {
  console.error(`artifact filename ${oldName} does not embed the version ${old}`);
  process.exit(1);
}
const bytes = fs.readFileSync(artifact);
const sha = crypto.createHash("sha256").update(bytes).digest("hex");
listing.release.id = version;
listing.release.version = version;
listing.release.contentRevision = "sha256-" + sha.slice(0, 16);
listing.release.artifacts[0].filename = filename;
listing.release.artifacts[0].size = bytes.length;
listing.release.artifacts[0].hashes.sha256 = sha;
listing.release.artifacts[0].download.url = "../files/" + filename;
fs.writeFileSync(listingPath, JSON.stringify(listing, null, 2) + "\n");

const catalog = JSON.parse(fs.readFileSync("site/catalog.json", "utf8"));
const today = new Date().toISOString().slice(0, 10);
const m = catalog.snapshotId.match(/^(\d{4}-\d{2}-\d{2})(?:-(\d+))?$/);
catalog.snapshotId = m && m[1] === today
  ? `${today}-${(Number(m[2]) || 0) + 1}`
  : `${today}-1`;
fs.writeFileSync("site/catalog.json", JSON.stringify(catalog, null, 2) + "\n");
fs.copyFileSync(artifact, path.join("site/files", filename));
console.log(`${id} ${version} -> ${filename} sha256-${sha.slice(0, 16)} snapshot ${catalog.snapshotId}`);
