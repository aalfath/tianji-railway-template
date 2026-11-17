# Tianji, official image pinned by version and digest.
# To update: change the tag and digest together, add a CHANGELOG.md entry, test, merge to main.
FROM moonrailgun/tianji:1.34.3@sha256:1fa262dcd64f6e9538bcd014392526ad67b27f60c7b07a6cff2b51c41345f368

COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh
COPY set-admin-password.mjs /app/tianji/src/server/set-admin-password.mjs

ENV NODE_ENV=production \
    PORT=12345

EXPOSE 12345

CMD ["/usr/local/bin/railway-start.sh"]
