#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <bundle_tar_gz> [version]"
  exit 2
fi

BUNDLE_PATH="$1"
VERSION="${2:-unknown}"

APP_DIR="/opt/PowerTune"
APP_BIN="${APP_DIR}/PowerTuneQMLGui"
BACKUP_BIN="${APP_DIR}/PowerTuneQMLGui.backup"
VERSION_FILE="${APP_DIR}/version.json"
MAINT_FLAG="/tmp/powertune-maintenance"

WORK_DIR="$(mktemp -d /tmp/powertune-update-XXXXXX)"
cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

if [[ ! -f "$BUNDLE_PATH" ]]; then
  echo "Bundle not found: $BUNDLE_PATH"
  exit 3
fi

touch "$MAINT_FLAG"

if [[ -x /etc/init.d/powertune ]]; then
  /etc/init.d/powertune stop || true
fi

if [[ ! -f "$APP_BIN" ]]; then
  echo "Current app binary not found at ${APP_BIN}"
  rm -f "$MAINT_FLAG"
  exit 4
fi

cp -f "$APP_BIN" "$BACKUP_BIN"

tar -xzf "$BUNDLE_PATH" -C "$WORK_DIR"

NEW_BIN="$(find "$WORK_DIR" -type f -name "PowerTuneQMLGui" | head -n 1)"
if [[ -z "$NEW_BIN" || ! -f "$NEW_BIN" ]]; then
  echo "Extracted bundle did not contain PowerTuneQMLGui"
  cp -f "$BACKUP_BIN" "$APP_BIN"
  rm -f "$MAINT_FLAG"
  exit 5
fi

install -m 0755 "$NEW_BIN" "$APP_BIN"

cat > "$VERSION_FILE" <<EOF
{
  "version": "${VERSION}",
  "installed_at_utc": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "bundle_path": "$(basename "$BUNDLE_PATH")"
}
EOF

if [[ -x /etc/init.d/powertune ]]; then
  if ! /etc/init.d/powertune start; then
    echo "Failed to start service after update; rolling back"
    cp -f "$BACKUP_BIN" "$APP_BIN"
    /etc/init.d/powertune start || true
    rm -f "$MAINT_FLAG"
    exit 6
  fi
fi

rm -f "$MAINT_FLAG"
echo "Update installed successfully"
