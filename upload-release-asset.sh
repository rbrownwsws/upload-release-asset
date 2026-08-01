#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "${FILE_PATH}" ]]; then
  echo "::error::file does not exist: ${FILE_PATH}" >&2
  exit 1
fi

if [[ -z "${ASSET_NAME:-}" ]]; then
  ASSET_NAME=$(basename "${FILE_PATH}")
fi

if [[ -z "${CONTENT_TYPE:-}" ]]; then
  CONTENT_TYPE=$(file --brief --mime "${FILE_PATH}")
fi

API_HEADERS=(
  --header "Accept: application/vnd.github+json"
  --header "Authorization: Bearer ${GITHUB_API_TOKEN}"
  --header "X-GitHub-Api-Version: 2026-03-10"
)

if [[ -z "${ASSET_NAME:-}" ]]; then
  ASSET_NAME=$(basename "${FILE_PATH}")
fi

ENCODED_ASSET_NAME=$(jq -nr --arg value "${ASSET_NAME}" '$value | @uri')

echo "Uploading ${FILE_PATH}"
echo "Name: ${ASSET_NAME}"
echo "Content-Type: ${CONTENT_TYPE}"
curl --silent --show-error --fail-with-body \
  --request POST \
  "${API_HEADERS[@]}" \
  --header "Content-Type: ${CONTENT_TYPE}" \
  --data-binary "@${FILE_PATH}" \
  "${UPLOAD_URL}?name=${ENCODED_ASSET_NAME}" >/dev/null
