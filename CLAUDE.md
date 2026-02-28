# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Docker Getting Started Tutorial — a full-stack todo app used as the subject of Docker's official tutorial. It combines a Node.js/Express REST API, a React frontend (Babel-transpiled in-browser), and a MkDocs documentation site, all packaged into a single Docker image served by Nginx.

## Commands

### App (Node.js — run from `app/`)
```bash
yarn install          # Install dependencies
yarn test             # Run Jest tests
yarn dev              # Start with nodemon (live reload)
yarn prettify         # Format code with Prettier
```

To run a single test file:
```bash
yarn test -- spec/routes/items.spec.js
```

### Documentation (MkDocs — run from project root)
```bash
pip install -r requirements.txt
mkdocs serve -a 0.0.0.0:8000   # Dev server
mkdocs build                    # Build static site
```

### Docker
```bash
docker-compose up               # Full dev environment (app + mkdocs live reload)
./build.sh                      # Build multi-platform Docker image
./build.sh --push               # Build and push to registry
```

## Architecture

### App (`app/`)
- **Entry point:** `src/index.js` — Express server on port 3000, serves static files and mounts routes
- **Routes:** `src/routes/items.js` — CRUD endpoints (`GET/POST /api/items`, `PUT/DELETE /api/items/:id`)
- **Persistence:** `src/persistence/` — auto-selects SQLite (default) or MySQL based on `MYSQL_HOST` env var; both implementations share the same interface
- **Frontend:** `src/static/` — React app loaded via `index.html`; JSX compiled in-browser via Babel (no build step for frontend)
- **Tests:** `spec/` — Jest tests mirroring `src/` structure

### Docker Image (multi-stage `Dockerfile`)
1. **Stage `docs`** — builds MkDocs docs into static HTML
2. **Stage `app-base`** — installs Node deps; runs tests
3. **Stage `app-zip`** — packages app source
4. **Final stage** — Nginx serves docs (port 80) and proxies `/api` to Node on port 3000

### Database switching
The persistence layer checks `process.env.MYSQL_HOST` at startup. If set, it uses `src/persistence/mysql.js`; otherwise falls back to `src/persistence/sqlite.js`. No code changes needed — only environment variables.

### Docker Compose (`docker-compose.yml`)
Mounts local source for live reload during development. Use this for iterating on both the app and docs simultaneously.
