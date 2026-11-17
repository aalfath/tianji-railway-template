#!/bin/sh
# Start Tianji on Railway: run database migrations (retrying until Postgres
# answers), replace the seeded admin/admin password, then start the server.
set -e
cd /app/tianji/src/server

export NODE_ENV=production
export PORT="${PORT:-12345}"
# Registration stays closed unless the deployer opens it on purpose.
export ALLOW_REGISTER="${ALLOW_REGISTER:-false}"

if [ -z "$DATABASE_URL" ]; then
  echo "[railway] DATABASE_URL is not set" >&2
  exit 1
fi

i=0
until ./node_modules/.bin/prisma migrate deploy; do
  i=$((i + 1))
  if [ "$i" -ge 30 ]; then
    echo "[railway] database migrations failed 30 times, giving up" >&2
    exit 1
  fi
  echo "[railway] database not ready yet, retrying in 3 s ($i/30)"
  sleep 3
done

node ./set-admin-password.mjs

# ClickHouse is optional (CLICKHOUSE_URL); the script skips itself when it is unset.
./node_modules/.bin/tsx ./clickhouse/scripts/apply.ts

# Built-in reporter: shows this container in Tianji's Server Status page,
# as the upstream image does.
(sleep 15; exec /usr/local/bin/tianji-reporter --url "http://localhost:${PORT}" \
  --workspace "clnzoxcy10001vy2ohi4obbi0" --name "tianji-container" --silent >/dev/null 2>&1) &

exec node ./dist/src/server/main.js
