# Web push + scraping + GitHub Actions (free-only) — Step-by-step for an AI coding agent

Goal

Create a reliable web-only push system (Firebase Cloud Messaging) and a scheduled GitHub Actions job that scrapes the pool status page, updates a JSON file served by GitHub Pages, and sends push notifications to web clients when the status changes — all using free tiers (Firebase Spark + GitHub Pages/Actions).

Summary of the approach

- Host the website on GitHub Pages (existing repo). Serve `firebase-messaging-sw.js` at the repository root path `/FloatIT-app/firebase-messaging-sw.js` so FCM can load it and register with scope under `/FloatIT-app/`.
- Use Firebase Cloud Messaging (web) for push. Use the Firebase Console / SDK on the client for token registration.
- Store tokens in Firestore (client writes) OR (alt) keep tokens in a repo file `tokens.json` that Action updates (less ideal but simpler). Firestore is supported on Spark and works for this use-case.
- Use GitHub Actions (cron) to run a Node script that:
  - Scrapes the pool HTML page.
  - Compares with last-known status (kept in repository `pool.json` in `gh-pages` branch) or in Firestore.
  - If status changed, reads tokens and sends FCM messages via the legacy HTTP endpoint (quick) or via the HTTP v1 API (recommended, needs service account token).
  - When changed, writes `pool.json` to the `gh-pages` branch so the web client can fetch it without CORS.

Files the agent will create or edit

- `web/firebase-messaging-sw.js` — FCM service worker (must be copied/present at repo root used by GitHub Pages: `/FloatIT-app/firebase-messaging-sw.js` after build/deploy)
- `web/index.html` — update SW registration to use absolute path `/FloatIT-app/firebase-messaging-sw.js` and a scope under `/FloatIT-app/`.
- `lib/src/services/pool_status_service.dart` (client) — change to fetch `/pool.json` (local) rather than hit CORS proxies, OR leave existing code and prefer `pool.json` where possible.
- `.github/workflows/scrape-and-notify.yml` — scheduled GitHub Actions workflow that runs the scraper and notifier.
- `tools/scrape_and_notify.js` — Node.js script run by the Action.
- `docs/WEB_PUSH_GH_ACTIONS.md` — (this file) for instructions and references.

Secrets the Action will need (store in GitHub repository secrets)

- `FIREBASE_SERVICE_ACCOUNT` — JSON of the Firebase service account (recommended for HTTP v1 API). The script parses this JSON directly.
- `FIREBASE_PROJECT_ID` — your Firebase project id (string, fallback if service account not provided).
- `FIREBASE_PRIVATE_KEY` — private key from service account (fallback).
- `FIREBASE_CLIENT_EMAIL` — client email from service account (fallback).
- `VAPID_PRIVATE_KEY` — private VAPID key for web push (optional, for custom flows).
- `VAPID_KEY` — public VAPID key (used in Flutter build for client-side token generation).

High-level steps for the agent (ordered)

1. Ensure `firebase-messaging-sw.js` exists in `web/` and that it contains `skipWaiting()` and `clients.claim()` and `importScripts('https://www.gstatic.com/firebasejs/.../firebase-app.js', 'https://www.gstatic.com/firebasejs/.../firebase-messaging.js')` or a self-contained handler for `onBackgroundMessage`.

2. Update `web/index.html` registration snippet (absolute path + scope):

```html
<script>
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    const swScript = '/FloatIT-app/firebase-messaging-sw.js';
    const swScope = '/FloatIT-app/firebase-cloud-messaging-push-scope';
    navigator.serviceWorker.register(swScript, { scope: swScope })
      .then(reg => console.log('FCM ServiceWorker registration successful with scope:', reg.scope))
      .catch(err => console.error('FCM SW registration failed:', err));
  });
}
</script>
```

3. On the web client (Dart/Flutter web):

- Use `firebase_messaging` web integration to call `messaging.getToken({vapidKey: 'YOUR_VAPID_KEY'})`.
- On successful token retrieval, write a document in Firestore `collection('web_tokens').doc(token).set({token, userAgent, createdAt})`.
- Also display UI permissions prompt and handle re-subscriptions or token refresh.

4. Replace client-side attempts to fetch the pool page through public proxies. Instead the client should fetch `/FloatIT-app/pool.json` (or `/pool.json` depending on base href) served by GitHub Pages. Update `lib/src/services/pool_status_service.dart` to prefer fetching that file (and fall back to current logic in non-web builds).

5. Create the GitHub Action workflow `.github/workflows/scrape-and-notify.yml` (example content below). The Action will:
- Run on schedule (e.g., `cron: '*/15 * * * *'` every 15 minutes).
- Checkout the repo.
- Setup Node.
- Install dependencies (cheerio, firebase-admin or node-fetch).
- Run `node tools/scrape_and_notify.js`.

Example `.github/workflows/scrape-and-notify.yml` (change as needed):

```yaml
name: Scrape Pool Status and Send Notifications

on:
  schedule:
    # Run every 15 minutes
    - cron: '*/15 * * * *'
  workflow_dispatch: # Allow manual triggering

jobs:
  scrape-and-notify:
    # Only run this job when the workflow is executed on the main branch.
    # This prevents scheduled/manual runs from other branches (for example `dev`).
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        persist-credentials: true
        
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: tools/package-lock.json
        
    - name: Install dependencies
      run: |
        cd tools
        npm ci
        
    - name: Run scraper and send notifications
      env:
        FIREBASE_SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
        VAPID_PRIVATE_KEY: ${{ secrets.VAPID_PRIVATE_KEY }}
      run: |
        cd tools
        node scrape_and_notify.js

    - name: Publish pool.json to gh-pages (create branch if missing)
      if: always()
      run: |
        git config user.name "github-actions[bot]"
        git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

        # Ensure pool.json exists in workspace
        if [ ! -f pool.json ]; then
          echo "pool.json not found, skipping publish"
          exit 0
        fi

        # Fetch remote branches
        git fetch origin

        if git ls-remote --exit-code --heads origin gh-pages; then
          # gh-pages exists remotely: check it out and update
          git checkout gh-pages
          git pull origin gh-pages
        else
          # Create orphan gh-pages branch
          git checkout --orphan gh-pages
          git rm -rf . || true
        fi

        # Copy the pool.json from the workspace root into the branch working tree
        cp ../pool.json ./pool.json 2>/dev/null || true
        git add pool.json

        if git diff --cached --quiet; then
          echo "No changes to commit on gh-pages"
        else
          git commit -m "chore: update pool.json from scrape workflow"
          git push origin HEAD:gh-pages
        fi
```

6. Create `tools/package.json` and `tools/scrape_and_notify.js`.

Minimal `tools/package.json` example:

```json
{
  "name": "floatit-scraper",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "cheerio": "^1.0.0-rc.12",
    "node-fetch": "^3.3.1",
    "firebase-admin": "^11.0.0"
  }
}
```

7. Create `tools/scrape_and_notify.js` (high-level behavior):

- Load service account JSON (if `FIREBASE_SERVICE_ACCOUNT` available) or use individual env vars as fallback.
- Fetch the pool page `https://svoemkbh.kk.dk/.../sundby-bad` using direct HTTPS request first, fall back to public CORS proxies if needed.
- Parse the HTML with `cheerio` to extract the status text.
- Compare with `pool.json` file in workspace (written by previous runs).
- If changed:
  - Read tokens from Firestore collection `fcm_tokens` using `firebase-admin`.
  - Send notifications via FCM HTTP v1 API using the service account.
  - Update `pool.json` in workspace with new status and timestamp.
- Publish `pool.json` to `gh-pages` branch for GitHub Pages serving.

8. Publishing `pool.json` on gh-pages (no CORS):
- The Action should checkout the `gh-pages` branch (or create it), write `pool.json`, commit and push. The web client can then fetch `https://floatit-itu.github.io/FloatIT-app/pool.json` without CORS problems.

9. Testing:
- Locally: run `node tools/scrape_and_notify.js` with environment variables set (you can use `.env` locally) and confirm it prints status and (optionally) sends messages to a test token.
- In GitHub Actions: manual dispatch to run once from the Actions tab.
- On web: grant notification permission, verify token stored in Firestore, simulate Action sending a test payload from Firebase Console or from your local script.

Quick example of the simplest FCM send (legacy) in Node:

```js
const fetch = require('node-fetch');
async function sendLegacy(token, title, body) {
  const key = process.env.FIREBASE_LEGACY_SERVER_KEY;
  const res = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${key}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      to: token,
      notification: { title, body }
    })
  });
  return res.json();
}
```

Notes / Caveats / Limitations

- Firestore quotas (Spark) are limited; for low volume (a few writes per user) this is OK. If your token list grows large or Actions frequently read many documents, monitor usage.
- GitHub Actions has execution time and concurrency limits; scheduled every 15 minutes is usually fine for low traffic.
- Adblockers and privacy extensions may block FCM or Firestore requests on the client — unavoidable.
- The scraper uses direct HTTPS fetch first for reliability, falling back to public CORS proxies only if needed.
- `pool.json` is published to `gh-pages` branch for CORS-free serving by GitHub Pages.

Security and secrets

- Put keys in GitHub Secrets. Never commit them to the repo.
- Limit token retention and provide an unsubscribe flow in the web client (delete the token document or mark it as disabled).

Optional improvements (later)

- Add rate-limiting, retries and exponential backoff in the Action script when sending to FCM.
- Use Cloudflare Worker instead of GitHub Actions for low-latency scrapes and as an API endpoint — easier CORS.
- Group tokens into topics/segments for fewer API calls.

---

If you want, I can now:

- create `web/firebase-messaging-sw.js` and `tools/scrape_and_notify.js` (quick mode using legacy FCM key),
- scaffold `.github/workflows/scrape-and-notify.yml`, and
- update `web/index.html` registration snippet and `lib/src/services/pool_status_service.dart` to use `/pool.json`.

Tell me which of the above to implement first and I will create the files, commit and (if you want) open a PR.