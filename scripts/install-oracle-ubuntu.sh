#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/minecraft/paper}"
SERVER_DIR="${SERVER_DIR:-${APP_DIR}/server}"
BACKUP_DIR="${BACKUP_DIR:-${APP_DIR}/backups}"
MINECRAFT_USER="${MINECRAFT_USER:-minecraft}"
SERVICE_NAME="${SERVICE_NAME:-minecraft-paper}"
HEAP_MIN="${MINECRAFT_HEAP_MIN:-1G}"
HEAP_MAX="${MINECRAFT_HEAP_MAX:-6G}"
USER_AGENT="${PAPER_USER_AGENT:-minecraft-paper-free-server/1.0 (https://github.com/fatzzu/minecraft-paper-free-server)}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script with sudo."
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This installer targets Ubuntu/Debian systems. Use an Ubuntu image on Oracle Cloud."
  exit 1
fi

java_major() {
  "$1" -version 2>&1 | awk -F '"' '/version/ { split($2, parts, "."); print parts[1]; exit }'
}

install_temurin_java25() {
  local machine
  local adoptium_arch
  local tmp_dir
  local archive
  local url

  machine="$(uname -m)"
  case "${machine}" in
    aarch64|arm64) adoptium_arch="aarch64" ;;
    x86_64|amd64) adoptium_arch="x64" ;;
    *)
      echo "Unsupported CPU architecture: ${machine}"
      exit 1
      ;;
  esac

  tmp_dir="$(mktemp -d)"
  archive="${tmp_dir}/temurin-java25.tar.gz"

  url="https://api.adoptium.net/v3/binary/latest/25/ga/linux/${adoptium_arch}/jre/hotspot/normal/eclipse"
  if ! curl -fL --retry 3 -A "${USER_AGENT}" -o "${archive}" "${url}"; then
    url="https://api.adoptium.net/v3/binary/latest/25/ga/linux/${adoptium_arch}/jdk/hotspot/normal/eclipse"
    curl -fL --retry 3 -A "${USER_AGENT}" -o "${archive}" "${url}"
  fi

  rm -rf "${APP_DIR}/runtime/java"
  mkdir -p "${APP_DIR}/runtime/java"
  tar -xzf "${archive}" -C "${APP_DIR}/runtime/java" --strip-components=1
  rm -rf "${tmp_dir}"
}

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [ ! -e "${dst}" ]; then
    install -m 0644 "${src}" "${dst}"
  else
    echo "Keeping existing file: ${dst}"
  fi
}

echo "Installing system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bash \
  ca-certificates \
  curl \
  git \
  jq \
  tar \
  gzip \
  coreutils

if ! id -u "${MINECRAFT_USER}" >/dev/null 2>&1; then
  useradd --system --home "${APP_DIR}" --shell /usr/sbin/nologin "${MINECRAFT_USER}"
fi

mkdir -p "${SERVER_DIR}" "${BACKUP_DIR}" "${APP_DIR}/runtime"

JAVA_BIN=""
if command -v java >/dev/null 2>&1; then
  current_major="$(java_major "$(command -v java)" || true)"
  if [ -n "${current_major}" ] && [ "${current_major}" -ge 25 ]; then
    JAVA_BIN="$(command -v java)"
  fi
fi

if [ -z "${JAVA_BIN}" ]; then
  echo "Installing Java 25 runtime..."
  install_temurin_java25
  JAVA_BIN="${APP_DIR}/runtime/java/bin/java"
fi

cat > /etc/minecraft-paper.env <<EOF
JAVA_BIN=${JAVA_BIN}
MINECRAFT_HEAP_MIN=${HEAP_MIN}
MINECRAFT_HEAP_MAX=${HEAP_MAX}
PAPER_JAR=paper.jar
EOF

copy_if_missing "${REPO_DIR}/server/server.properties" "${SERVER_DIR}/server.properties"
copy_if_missing "${REPO_DIR}/server/eula.txt" "${SERVER_DIR}/eula.txt"
copy_if_missing "${REPO_DIR}/server/whitelist.json" "${SERVER_DIR}/whitelist.json"
copy_if_missing "${REPO_DIR}/server/ops.json" "${SERVER_DIR}/ops.json"
mkdir -p "${SERVER_DIR}/plugins"
cp -a "${REPO_DIR}/server/plugins/." "${SERVER_DIR}/plugins/" 2>/dev/null || true

SERVER_DIR="${SERVER_DIR}" PAPER_USER_AGENT="${USER_AGENT}" bash "${REPO_DIR}/scripts/download-paper.sh"

install -m 0644 "${REPO_DIR}/systemd/minecraft-paper.service" "/etc/systemd/system/${SERVICE_NAME}.service"
install -m 0755 "${REPO_DIR}/scripts/backup.sh" /usr/local/sbin/minecraft-paper-backup

if command -v ufw >/dev/null 2>&1 && ufw status | grep -qi "Status: active"; then
  ufw allow 25565/tcp
fi

if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-port=25565/tcp
  firewall-cmd --reload
fi

chown -R "${MINECRAFT_USER}:${MINECRAFT_USER}" "${APP_DIR}"
systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"

echo
echo "Install complete."
echo "Next:"
echo "  sudo bash scripts/add-player.sh YourMinecraftName op"
echo "  sudo bash scripts/accept-eula.sh"
echo
echo "Also open TCP port 25565 in the Oracle Cloud VCN/Security List/NSG."
