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
# Clone and install
git clone https://github.com/yourname/nikke-union-raid.git
cd nikke-union-raid

# Log in to Cloudflare
wrangler login

# Set auth credentials (you'll be prompted to enter values)
wrangler secret put OCR_USER
wrangler secret put OCR_PASS

# Deploy
wrangler deploy
```

The worker will be live at `https://nikke-union-raid.<your-subdomain>.workers.dev`.

### Bindings

The `wrangler.toml` already declares the Workers AI binding. No manual setup needed when using `wrangler deploy`.

If deploying via the Cloudflare dashboard instead:
1. Workers & Pages → your worker → Settings → Bindings
2. Add binding: Type **Workers AI**, Variable name **`AI`**

## Adding new characters

Edit `src/characters.js` only — both the AI prompt and the frontend dropdown will pick up the change on the next deploy.

## OCR Authentication

The `/ocr` endpoint requires HTTP Basic Auth. Users enter their credentials once in the app's "OCR Authentication" panel and they're saved to localStorage.

Share the username and password with your guildmates — they don't need a Cloudflare account.
