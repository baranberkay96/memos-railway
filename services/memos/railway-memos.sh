#!/bin/sh
# Start Memos on Railway.
# Writes a declarative configuration file (Memos applies it at startup, after the
# database migration and before it serves): an administrator "admin" with the
# password from MEMOS_ADMIN_PASSWORD, and self-registration as set by
# MEMOS_ALLOW_REGISTRATION. Bad values fall back to safe defaults with a warning.
set -u
log() { echo "[railway] $*"; }

CONFIG_DIR=/etc/memos/railway
MIN_PASSWORD=12

case "${PORT:-}" in
  ''|*[!0-9]*) log "PORT '${PORT:-}' is not a number; using 5230"; PORT=5230 ;;
esac
export MEMOS_PORT="$PORT"
export MEMOS_DATA="${MEMOS_DATA:-/var/opt/memos}"
export MEMOS_CONFIG_DIR="$CONFIG_DIR"
export MEMOS_CONFIG_APPLY=startup

# Admin password: write-only in Memos, sent on the first start and whenever
# MEMOS_ADMIN_LOGIN_VERSION goes up (so a password changed in the UI survives restarts).
ADMIN_PASSWORD="${MEMOS_ADMIN_PASSWORD:-}"
if [ "${#ADMIN_PASSWORD}" -lt "$MIN_PASSWORD" ]; then
  log "WARNING: MEMOS_ADMIN_PASSWORD is shorter than ${MIN_PASSWORD} characters. If the admin is created (or the"
  log "         password re-applied) with this start, the login is locked with a random password. Set a longer one,"
  log "         raise MEMOS_ADMIN_LOGIN_VERSION by 1 and redeploy."
  ADMIN_PASSWORD=$(head -c 48 /dev/urandom | od -An -tx1 | tr -d ' \n')
fi
export RAILWAY_MEMOS_ADMIN_PASSWORD="$ADMIN_PASSWORD"
unset MEMOS_ADMIN_PASSWORD

VERSION="${MEMOS_ADMIN_LOGIN_VERSION:-1}"
case "$VERSION" in
  ''|*[!0-9]*) log "MEMOS_ADMIN_LOGIN_VERSION '${VERSION}' is not a number; using 1"; VERSION=1 ;;
esac
[ "$VERSION" -ge 1 ] 2>/dev/null || VERSION=1

case "$(printf '%s' "${MEMOS_ALLOW_REGISTRATION:-false}" | tr 'A-Z' 'a-z')" in
  1|true|yes|on) DISALLOW=false; log "self-registration is ON (MEMOS_ALLOW_REGISTRATION=true)" ;;
  *) DISALLOW=true ;;
esac

mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/railway.json" <<JSON
{
  "users": [
    { "name": "users/admin", "username": "admin", "role": "ADMIN", "password": "\${env:RAILWAY_MEMOS_ADMIN_PASSWORD}" }
  ],
  "instanceSettings": [
    { "name": "instance/settings/GENERAL", "generalSetting": { "disallowUserRegistration": ${DISALLOW} } }
  ],
  "lifecycle": [
    { "resource": "users/admin", "preventDestroy": true, "writeOnlyVersion": ${VERSION} },
    { "resource": "instance/settings/GENERAL", "ignoreChanges": [
      "generalSetting.customProfile", "generalSetting.disallowPasswordAuth", "generalSetting.disallowChangeUsername",
      "generalSetting.disallowChangeNickname", "generalSetting.weekStartDayOffset", "generalSetting.additionalStyle",
      "generalSetting.additionalScript" ] }
  ]
}
JSON
chmod 0644 "$CONFIG_DIR/railway.json"

log "admin user: admin (password version ${VERSION}); registration disallowed: ${DISALLOW}"
exec /usr/local/memos/entrypoint.sh /usr/local/memos/memos
