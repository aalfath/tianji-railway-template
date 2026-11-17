[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/tianji?utm_medium=integration&utm_source=button&utm_campaign=tianji)

# Tianji on Railway

One-click Railway template for [Tianji](https://github.com/msgbyte/tianji): website analytics, uptime monitoring and server status in one self-hosted app.

## What it deploys

| Service | Source | Notes |
| --- | --- | --- |
| **Tianji** | this repo (`Dockerfile`), based on the official image `moonrailgun/tianji:1.34.3` pinned by digest | Public HTTPS domain, health check on `/health`, listens on port 12345 |
| **Postgres** | Railway's PostgreSQL | All Tianji data (users, websites, events, monitors) lives here, on a Railway volume |

The wrapper is small:

- `railway-start.sh` runs the database migrations (retrying until Postgres answers), replaces Tianji's seeded `admin`/`admin` password with `ADMIN_PASSWORD`, applies ClickHouse migrations only if you set `CLICKHOUSE_URL`, and starts the server and the built-in server-status reporter.
- `set-admin-password.mjs` changes the admin password only while it is still the default `admin`. A password you changed in Tianji is never touched again.
- Open registration is off (`ALLOW_REGISTER=false`) unless you set it to `true`.

## Variables

| Variable | Default | What it does |
| --- | --- | --- |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Connection to the bundled Postgres over the private network |
| `JWT_SECRET` | generated | Signs login sessions; keeps you logged in across redeploys |
| `ADMIN_PASSWORD` | generated | Password for the `admin` user on first start. Read it in the Tianji service's Variables tab |
| `PORT` | `12345` | Port Tianji listens on |

Optional settings (SMTP, OAuth login, Redis cache, ClickHouse, OpenAI features, `PUBLIC_URL`) are described in Tianji's [environment variable docs](https://tianji.dev/docs/install/environment). Add them to the Tianji service when you need them.

## After deploy

1. Open the public URL and sign in as `admin` with the `ADMIN_PASSWORD` value from the Variables tab.
2. Change the password under your profile, then add a website or a monitor.
3. To track a website, copy the tracking script Tianji shows for it into your site.

## Updates

The Dockerfile pins one Tianji release by version and digest. When a new release is tested here, the pin is bumped on `main` and listed in [CHANGELOG.md](CHANGELOG.md). Railway then shows deployers an "update available" notice, and you choose when to apply it. Tianji runs its database migrations on start, so read the changelog's breaking-change notes and back up Postgres before a major upgrade.

## Local test

```sh
docker compose -f compose.test.yml up -d --build
# open http://localhost:42463 and sign in as admin / local-test-admin-pw-123
```

Tianji is licensed under Apache-2.0 by msgbyte. This repo only packages it for Railway.
