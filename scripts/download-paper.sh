#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PAPER_PROJECT:-paper}"
SERVER_DIR="${SERVER_DIR:-/opt/minecraft/paper/server}"
JAR_NAME="${PAPER_JAR:-paper.jar}"
MC_VERSION="${MC_VERSION:-latest}"
USER_AGENT="${PAPER_USER_AGENT:-minecraft-paper-free-server/1.0 (https://github.com/fatzzu/minecraft-paper-free-server)}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing command: $1"
    exit 1
  fi
}

paper_versions() {
  curl -fsSL -H "User-Agent: ${USER_AGENT}" \
    "https://fill.papermc.io/v3/projects/${PROJECT}" |
    jq -r '.versions | to_entries[] | .value[]' |
    sort -V -r
}

stable_url_for_version() {
  local version="$1"
  curl -fsSL -H "User-Agent: ${USER_AGENT}" \
    "https://fill.papermc.io/v3/projects/${PROJECT}/versions/${version}/builds" |
    jq -r 'first(.[] | select(.channel == "STABLE") | .downloads."server:default".url) // "null"'
}

require_command curl
require_command jq
require_command sort

mkdir -p "${SERVER_DIR}"
cd "${SERVER_DIR}"

if [ "${MC_VERSION}" = "latest" ]; then
  MC_VERSION="$(paper_versions | head -n 1)"
fi

PAPER_URL="$(stable_url_for_version "${MC_VERSION}" || true)"

if [ -z "${PAPER_URL}" ] || [ "${PAPER_URL}" = "null" ]; then
  echo "No stable Paper build found for ${MC_VERSION}. Searching latest stable version..."
  while IFS= read -r version; do
    PAPER_URL="$(stable_url_for_version "${version}" || true)"
    if [ -n "${PAPER_URL}" ] && [ "${PAPER_URL}" != "null" ]; then
      MC_VERSION="${version}"
      break
    fi
  done < <(paper_versions)
fi

if [ -z "${PAPER_URL}" ] || [ "${PAPER_URL}" = "null" ]; then
  echo "No stable Paper build could be found."
  exit 1
fi

tmp_file="$(mktemp)"
echo "Downloading Paper ${MC_VERSION}..."
curl -fL --retry 3 -H "User-Agent: ${USER_AGENT}" -o "${tmp_file}" "${PAPER_URL}"
mv "${tmp_file}" "${JAR_NAME}"
echo "${MC_VERSION}" > .paper-version

echo "Paper installed at ${SERVER_DIR}/${JAR_NAME}"
