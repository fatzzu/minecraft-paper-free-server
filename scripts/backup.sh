#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-/opt/minecraft/paper/server}"
BACKUP_DIR="${BACKUP_DIR:-/opt/minecraft/paper/backups}"
SERVICE_NAME="${SERVICE_NAME:-minecraft-paper}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
STOP_SERVER_FOR_BACKUP="${STOP_SERVER_FOR_BACKUP:-false}"

mkdir -p "${BACKUP_DIR}"

was_running="false"
if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet "${SERVICE_NAME}"; then
  was_running="true"
fi

if [ "${STOP_SERVER_FOR_BACKUP}" = "true" ] && [ "${was_running}" = "true" ]; then
  systemctl stop "${SERVICE_NAME}"
  trap 'systemctl start "${SERVICE_NAME}"' EXIT
fi

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
dest="${BACKUP_DIR}/minecraft-paper-${stamp}.tar.gz"

tar -czf "${dest}" \
  --exclude='./cache' \
  --exclude='./crash-reports' \
  --exclude='./logs' \
  --exclude='./libraries' \
  -C "${SERVER_DIR}" .

find "${BACKUP_DIR}" -type f -name 'minecraft-paper-*.tar.gz' -mtime +"${RETENTION_DAYS}" -delete

echo "Backup created: ${dest}"
