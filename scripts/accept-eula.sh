#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-/opt/minecraft/paper/server}"
SERVICE_NAME="${SERVICE_NAME:-minecraft-paper}"
MINECRAFT_USER="${MINECRAFT_USER:-minecraft}"
EULA_URL="https://aka.ms/MinecraftEULA"

echo "Minecraft server EULA:"
echo "  ${EULA_URL}"
echo
read -r -p "Type ACCEPT if you have read and agree to the EULA: " answer

if [ "${answer}" != "ACCEPT" ]; then
  echo "EULA was not accepted. Server will not be started."
  exit 1
fi

mkdir -p "${SERVER_DIR}"
cat > "${SERVER_DIR}/eula.txt" <<EOF
# Accepted by the server owner after reading:
# ${EULA_URL}
eula=true
EOF

if id -u "${MINECRAFT_USER}" >/dev/null 2>&1; then
  chown "${MINECRAFT_USER}:${MINECRAFT_USER}" "${SERVER_DIR}/eula.txt" 2>/dev/null || true
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl start "${SERVICE_NAME}"
  systemctl status "${SERVICE_NAME}" --no-pager || true
else
  echo "EULA accepted. Start the server with your normal Java command."
fi
