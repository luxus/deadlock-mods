// Deadlock Lobby Ranks party bridge. Input: ?v=1&n=<nonce>&a=<ids>&b=<ids>
// Output: document.title = 'LRPARTY1 ' + JSON {n, ok, g?, e?}; g = list of same-team friend groups (2+ ids).
(function () {
	'use strict';
	var PREFIX = 'LRPARTY1 ';
	var API = 'https://api.deadlock-api.com/v1/players/steam?account_ids=';
	var out = document.getElementById('out');
	var finish = function (obj) {
		var t = PREFIX + JSON.stringify(obj);
		document.title = t;
		try { location.hash = encodeURIComponent(t); } catch (e) {}
		if (out) out.textContent = t;
	};
	var ids = function (s) {
		if (!s) return [];
		var list = String(s).split(',');
		var res = [];
		for (var i = 0; i < list.length; i++) {
			var v = list[i].trim();
			if (!/^[1-9]\d{0,9}$/.test(v) || Number(v) > 4294967295) return null;
			if (res.indexOf(v) < 0) res.push(v);
		}
		return res.length <= 12 ? res : null;
	};
	var q = new URLSearchParams(location.search);
	var n = q.get('n') || '';
	if (q.get('v') !== '1' || !/^[A-Za-z0-9]{1,32}$/.test(n)) { finish({ n: n.replace(/[^A-Za-z0-9]/g, '').slice(0, 32), ok: 0, e: 'bad_request' }); return; }
	var a = ids(q.get('a')), b = ids(q.get('b'));
	if (!a || !b || a.length + b.length === 0) { finish({ n: n, ok: 0, e: 'bad_ids' }); return; }
	var team = {};
	a.forEach(function (x) { team[x] = 'a'; });
	b.forEach(function (x) { team[x] = team[x] ? 'x' : 'b'; });
	var all = Object.keys(team).filter(function (x) { return team[x] !== 'x'; }).sort(function (x, y) { return Number(x) - Number(y); });
	var ctl = typeof AbortController === 'function' ? new AbortController() : null;
	var timer = setTimeout(function () { if (ctl) ctl.abort(); }, 15000);
	fetch(API + all.join(','), ctl ? { signal: ctl.signal } : {}).then(function (r) {
		if (!r.ok) throw new Error('http_' + r.status);
		return r.json();
	}).then(function (data) {
		clearTimeout(timer);
		if (!Array.isArray(data)) throw new Error('bad_payload');
		var up = {};
		all.forEach(function (x) { up[x] = x; });
		var root = function (x) { while (up[x] !== x) { up[x] = up[up[x]]; x = up[x]; } return x; };
		data.forEach(function (p) {
			if (!p || p.account_id === undefined) return;
			var me = String(p.account_id);
			if (!(me in up)) return;
			(Array.isArray(p.friends) ? p.friends : []).forEach(function (f) {
				var other = String(f && typeof f === 'object' ? f.account_id : f);
				if (other in up && other !== me && team[other] === team[me]) up[root(other)] = root(me);
			});
		});
		var groups = {};
		all.forEach(function (x) { var r = root(x); (groups[r] = groups[r] || []).push(x); });
		var g = Object.keys(groups).map(function (k) { return groups[k].sort(function (x, y) { return Number(x) - Number(y); }); })
			.filter(function (m) { return m.length > 1; })
			.sort(function (x, y) { return Number(x[0]) - Number(y[0]); });
		finish({ n: n, ok: 1, g: g, c: data.length });
	}).catch(function (err) {
		clearTimeout(timer);
		finish({ n: n, ok: 0, e: String(err && err.name === 'AbortError' ? 'timeout' : (err && err.message) || err).slice(0, 40) });
	});
})();
