# Development guide

How the project is put together and how to maintain a deployed copy. Setting
up a deployment is described in the [README](../README.md#hosting-your-own-copy).

## Layout

```
src/
  worker.js      Cloudflare Worker entry point
                   GET  /     serves the page
                   POST /ocr  reads a screenshot (Basic Auth required)
  characters.js  The list of Nikke names, used both in the AI prompt and in
                 the page's character picker
  page.html      The whole front end: HTML, CSS and JavaScript in one file
schema.sql       Table for the scan log (D1)
wrangler.toml    Worker configuration: bindings, route, observability
```

The page has no build step. The worker imports `page.html` as text and
replaces the `/* __CHARACTERS_PLACEHOLDER__ */` comment with the contents of
`characters.js`, so the character list lives in one place.

The optimizer runs entirely in the browser. Teams, locks and dead bosses are
kept in `localStorage` under `union_raid_v2`, and the OCR login under
`cf_ocr_auth_v1`.

## Adding new Nikkes

Edit `src/characters.js` and deploy. The page's character picker and the
names the AI is asked to match both come from that list.

Variants use the `Name: Variant` form (for example `Anis: Sparkling Summer`).
The screenshot matcher relies on that: when the game cuts a name short, it
still finds the full name from the part after the colon.

## Running it locally

```bash
npx wrangler dev
```

This serves the page at `http://localhost:8787`. Workers AI always runs on
Cloudflare, even in local mode, so scans count towards your usage. The D1
log goes to a local database unless you add `--remote`. Logins come from a
`.dev.vars` file in the project root (it's ignored by git):

```
OCR_USER=admin
OCR_PASS=change-me
UNION_USER=union
UNION_PASS=change-me
```

For the local database, apply the schema once with
`npx wrangler d1 execute ocr-logs --local --file=./schema.sql`.

## Reading the scan log

Every request to `/ocr` is written to the `audit_logs` table after the
response is sent. A failed write never affects the scan. `username` is empty
for requests with a wrong login, and `ai_ok` is empty when the request never
reached the AI.

```bash
# The 50 most recent requests
npx wrangler d1 execute ocr-logs --remote --command \
  "SELECT timestamp, ip, country, username, status_code, ai_ok, duration_ms FROM audit_logs ORDER BY timestamp DESC LIMIT 50"

# Requests with a wrong login
npx wrangler d1 execute ocr-logs --remote --command \
  "SELECT timestamp, ip, country FROM audit_logs WHERE username IS NULL ORDER BY timestamp DESC"

# Requests from one IP address
npx wrangler d1 execute ocr-logs --remote --command \
  "SELECT * FROM audit_logs WHERE ip = '1.2.3.4' ORDER BY timestamp DESC"
```

The `cf_ray` column holds Cloudflare's Ray ID for the request, which
Cloudflare support can use to look into a specific request.
