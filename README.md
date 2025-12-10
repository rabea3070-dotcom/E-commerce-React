# Fashion Cube — E‑commerce Demo

A lightweight ecommerce demo built with React (frontend) and a small Express server (backend). This repository contains a complete example app you can run locally for development, testing, or to use as a starting point for your own shop UI.

Live demo: https://quintuslabs.github.io/fashion-cube

Key technologies

- Frontend: React, Redux, Axios, react-bootstrap, Sass
- Backend (example): Node + Express, Mongoose (optional), simple session/auth modules

Highlights

- Responsive product listing and product detail pages
- Cart flow and checkout stub
- Basic auth scaffolding (register/login)

Quick start (recommended)

1) Clone the repo:

```powershell
git clone https://github.com/rabea3070-dotcom/E-commerce-React.git
cd E-commerce-React
```

2) Apply local run fixes (optional helper is provided in this workspace at `run-fixes/apply-fixes.ps1`):

```powershell
# If you copied the helper scripts into your repo root:
.\run-fixes\apply-fixes.ps1 -RepoPath .

# Or manually install deps and run (Windows PowerShell):
npm install
$env:NODE_OPTIONS='--openssl-legacy-provider'
npm start
```

Notes

- If you don't have MongoDB running locally the backend will fall back to an in-memory MongoDB (development only) so you can run the app without setting up a full database.
- On Node 17+ you may see an OpenSSL/webpack error; the helper script sets NODE_OPTIONS to `--openssl-legacy-provider` to work around this for local dev.

Project structure (short)

- `src/` — React app
- `server/ecommerce/` — example Express backend (routes, models, config)
- `public/` — static assets

How you can help this repo look great

- Replace the placeholder images in `public/images` and `screen/` with higher‑resolution product shots.
- Add a project logo to `public/favicon.ico` and update `public/index.html` meta tags.
- Tidy up accessibility warnings (several `href` attributes are placeholders). See the console warnings produced by `npm start`.

License

This project is provided as-is for learning and demo purposes. Feel free to fork and adapt it.

If you'd like, I can: create a polished README with screenshots embedded, prepare a production build and deploy guide, and open a PR with small UI polish (hero banner, favicon, README screenshots). Say which one you'd like next and I'll prepare it.
