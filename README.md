# NIKKE Union Raid Optimizer

A Cloudflare Worker that serves the Union Raid team optimizer and provides an OCR endpoint for scanning battle result screenshots.

## Structure

```
src/
  worker.js      — Cloudflare Worker entry point
                   GET  /     → serves the app
                   POST /ocr  → OCR endpoint (Basic Auth required)
  characters.js  — Single source of truth for all NIKKE character names
                   Imported by the worker for the AI prompt, and injected
                   into the page at serve time
  page.html      — Frontend (CHARACTERS list is injected by the worker,
                   not hardcoded)
wrangler.toml    — Cloudflare Workers config
```

## Setup

### Prerequisites

- [Cloudflare account](https://dash.cloudflare.com/sign-up)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/) (`npm install -g wrangler`)

### Deploy

```bash
# Clone
git clone https://github.com/yourname/nikke-union-raid.git
cd nikke-union-raid

# Log in to Cloudflare
wrangler login

# Create the D1 database — copy the database_id it prints into wrangler.toml
npx wrangler d1 create ocr-logs

# Apply the schema
npx wrangler d1 execute ocr-logs --remote --file=./schema.sql

# Set secrets
wrangler secret put OCR_USER    # your personal admin username
wrangler secret put OCR_PASS    # your personal admin password
wrangler secret put UNION_USER  # shared guild username
wrangler secret put UNION_PASS  # shared guild password

# Deploy
wrangler deploy
```

### Querying the audit log

```bash
# All requests in the last 24 hours
npx wrangler d1 execute ocr-logs --remote --command \
  "SELECT timestamp, ip, country, username, status_code, ai_ok, duration_ms FROM audit_logs ORDER BY timestamp DESC LIMIT 50"

# All failed auth attempts
npx wrangler d1 execute ocr-logs --remote --command \
  "SELECT timestamp, ip, country FROM audit_logs WHERE username IS NULL ORDER BY timestamp DESC"

# Requests by a specific IP
npx wrangler d1 execute ocr-logs --remote --command \
  "SELECT * FROM audit_logs WHERE ip = '1.2.3.4' ORDER BY timestamp DESC"
```

## Adding new characters

Edit `src/characters.js` only — both the AI prompt and the frontend dropdown will pick up the change on the next deploy.

## OCR Authentication

The `/ocr` endpoint requires HTTP Basic Auth. Users enter their credentials once in the app's "OCR Authentication" panel and they're saved to localStorage.

Share the username and password with your guildmates — they don't need a Cloudflare account.
