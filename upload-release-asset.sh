#!/usr/bin/env bash
set -euo pipefail

API_HEADERS=(
  --header "Accept: application/vnd.github+json"
  --header "Authorization: Bearer ${GITHUB_API_TOKEN}"
  --header "X-GitHub-Api-Version: 2026-03-10"
)

mapfile -t files < <(compgen -G "${ASSETS_PATH}")

if [[ ${#files[@]} -eq 0 ]]; then
    echo "::error::No files matched: ${ASSETS_PATH}"
    exit 1
fi

for file in "${files[@]}"; do
  echo "::group::Uploading ${file}"

  asset_name=$(basename "${file}")

  if [[ -n "${CONTENT_TYPE:-}" ]]; then
    asset_content_type="${CONTENT_TYPE}"
  else
    asset_content_type=$(file --brief --mime "${file}")
  fi

  echo "Name: ${asset_name}"
  echo "Content-Type: ${asset_content_type}"

  encoded_asset_name=$(jq -nr --arg value "${asset_name}" '$value | @uri')

  curl --silent --show-error --fail-with-body \
    --request POST \
    "${API_HEADERS[@]}" \
    --header "Content-Type: ${asset_content_type}" \
    --data-binary "@${file}" \
    "${UPLOAD_URL}?name=${encoded_asset_name}" >/dev/null

  echo "::endgroup::"
done
