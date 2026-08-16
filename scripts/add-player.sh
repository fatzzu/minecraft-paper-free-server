#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-/opt/minecraft/paper/server}"
SERVICE_NAME="${SERVICE_NAME:-minecraft-paper}"
MINECRAFT_USER="${MINECRAFT_USER:-minecraft}"

PLAYER="${1:-}"
ROLE="${2:-player}"

if [ -z "${PLAYER}" ]; then
  echo "Usage: sudo bash scripts/add-player.sh MinecraftName [player|op]"
  exit 1
fi

if [ "${ROLE}" != "player" ] && [ "${ROLE}" != "op" ]; then
  echo "Role must be 'player' or 'op'."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  echo "This script needs curl and jq."
  exit 1
fi

format_uuid() {
  sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/'
}

ensure_json_array() {
  local file="$1"
  if [ ! -s "${file}" ]; then
    echo "[]" > "${file}"
  fi
  if ! jq -e 'type == "array"' "${file}" >/dev/null; then
    echo "${file} must contain a JSON array."
    exit 1
  fi
}

mkdir -p "${SERVER_DIR}"

profile="$(curl -fsSL "https://api.mojang.com/users/profiles/minecraft/${PLAYER}" || true)"
if [ -z "${profile}" ]; then
  echo "Could not find a Minecraft Java profile for: ${PLAYER}"
  exit 1
fi

uuid_raw="$(echo "${profile}" | jq -r '.id // empty')"
name="$(echo "${profile}" | jq -r '.name // empty')"

if [ -z "${uuid_raw}" ] || [ -z "${name}" ]; then
  echo "Invalid profile response for: ${PLAYER}"
  exit 1
fi

uuid="$(echo "${uuid_raw}" | format_uuid)"
whitelist="${SERVER_DIR}/whitelist.json"
ops="${SERVER_DIR}/ops.json"

ensure_json_array "${whitelist}"
tmp="$(mktemp)"
jq --arg uuid "${uuid}" --arg name "${name}" \
  'map(select(.uuid != $uuid and .name != $name)) + [{"uuid": $uuid, "name": $name}]' \
  "${whitelist}" > "${tmp}"
install -m 0644 "${tmp}" "${whitelist}"
rm -f "${tmp}"

if [ "${ROLE}" = "op" ]; then
  ensure_json_array "${ops}"
  tmp="$(mktemp)"
  jq --arg uuid "${uuid}" --arg name "${name}" \
    'map(select(.uuid != $uuid and .name != $name)) + [{"uuid": $uuid, "name": $name, "level": 4, "bypassesPlayerLimit": false}]' \
    "${ops}" > "${tmp}"
  install -m 0644 "${tmp}" "${ops}"
  rm -f "${tmp}"
fi

if id -u "${MINECRAFT_USER}" >/dev/null 2>&1; then
  chown "${MINECRAFT_USER}:${MINECRAFT_USER}" "${whitelist}" "${ops}" 2>/dev/null || true
fi

echo "Added ${name} (${uuid}) as ${ROLE}."

if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet "${SERVICE_NAME}"; then
  systemctl restart "${SERVICE_NAME}"
  echo "Restarted ${SERVICE_NAME}."
fi
