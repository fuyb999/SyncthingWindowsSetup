#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/syncthing-build-assets.XXXXXX")"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

download_json() {
  local owner="$1"
  local repo="$2"
  curl -fsSL "https://api.github.com/repos/${owner}/${repo}/releases/latest"
}

first_asset_url() {
  local json="$1"
  local pattern="$2"
  jq -r --arg pattern "$pattern" '
    .assets[]
    | select(.name | test($pattern))
    | .browser_download_url
  ' <<<"$json" | head -n 1
}

release_tag() {
  local json="$1"
  jq -r '.tag_name' <<<"$json"
}

download_file() {
  local url="$1"
  local dest="$2"
  echo "Downloading $(basename "$dest")"
  curl -fL --retry 3 --retry-delay 1 -o "$dest" "$url"
}

extract_file() {
  local zip_file="$1"
  local member="$2"
  local dest="$3"
  unzip -p "$zip_file" "$member" > "$dest"
  chmod 755 "$dest"
}

download_dual_arch_tool() {
  local owner="$1"
  local repo="$2"
  local asset_pattern="$3"
  local exe_name="$4"
  local json tag url zip_file

  json="$(download_json "$owner" "$repo")"
  tag="$(release_tag "$json")"
  url="$(first_asset_url "$json" "$asset_pattern")"
  if [[ -z "$url" ]]; then
    echo "Failed to find asset for ${owner}/${repo}" >&2
    exit 1
  fi

  zip_file="${TMP_DIR}/${repo}.zip"
  download_file "$url" "$zip_file"
  extract_file "$zip_file" "i386/${exe_name}"   "${ROOT_DIR}/binaries/i386/${exe_name}"
  extract_file "$zip_file" "x86_64/${exe_name}" "${ROOT_DIR}/binaries/x86_64/${exe_name}"
  printf '%s\t%s\n' "${repo}" "${tag}" >> "${TMP_DIR}/versions.tsv"
}

download_shawl() {
  local json tag url32 url64 zip32 zip64

  json="$(download_json "mtkennerly" "shawl")"
  tag="$(release_tag "$json")"
  url32="$(first_asset_url "$json" 'shawl-.*-win32\.zip$')"
  url64="$(first_asset_url "$json" 'shawl-.*-win64\.zip$')"
  if [[ -z "$url32" || -z "$url64" ]]; then
    echo "Failed to find shawl assets" >&2
    exit 1
  fi

  zip32="${TMP_DIR}/shawl-win32.zip"
  zip64="${TMP_DIR}/shawl-win64.zip"
  download_file "$url32" "$zip32"
  download_file "$url64" "$zip64"
  extract_file "$zip32" "shawl.exe" "${ROOT_DIR}/binaries/i386/shawl.exe"
  extract_file "$zip64" "shawl.exe" "${ROOT_DIR}/binaries/x86_64/shawl.exe"
  printf '%s\t%s\n' "shawl" "${tag}" >> "${TMP_DIR}/versions.tsv"
}

download_syncthing_zips() {
  local json tag url386 urlamd64 urlarm64

  json="$(download_json "syncthing" "syncthing")"
  tag="$(release_tag "$json")"
  url386="$(first_asset_url "$json" 'syncthing-windows-386-v.*\.zip$')"
  urlamd64="$(first_asset_url "$json" 'syncthing-windows-amd64-v.*\.zip$')"
  urlarm64="$(first_asset_url "$json" 'syncthing-windows-arm64-v.*\.zip$')"
  if [[ -z "$url386" || -z "$urlamd64" || -z "$urlarm64" ]]; then
    echo "Failed to find Syncthing Windows zip assets" >&2
    exit 1
  fi

  download_file "$url386"   "${ROOT_DIR}/offline/syncthing-windows-386.zip"
  download_file "$urlamd64" "${ROOT_DIR}/offline/syncthing-windows-amd64.zip"
  download_file "$urlarm64" "${ROOT_DIR}/offline/syncthing-windows-arm64.zip"
  printf '%s\t%s\n' "syncthing" "${tag}" >> "${TMP_DIR}/versions.tsv"
}

write_versions_file() {
  {
    echo "Downloaded build assets"
    echo
    sort "${TMP_DIR}/versions.tsv" | while IFS=$'\t' read -r name tag; do
      printf '%s %s\n' "$name" "$tag"
    done
  } > "${ROOT_DIR}/build-assets.versions.txt"
}

require_cmd curl
require_cmd jq
require_cmd unzip
require_cmd mktemp

mkdir -p "${ROOT_DIR}/binaries/i386" "${ROOT_DIR}/binaries/x86_64" "${ROOT_DIR}/offline"
: > "${TMP_DIR}/versions.tsv"

download_dual_arch_tool "Bill-Stewart" "asmt" '.*\.zip$' "asmt.exe"
download_dual_arch_tool "Bill-Stewart" "ErrInfo" '.*\.zip$' "ErrInfo.exe"
download_dual_arch_tool "Bill-Stewart" "ServMan" '.*\.zip$' "ServMan.exe"
download_dual_arch_tool "Bill-Stewart" "stctl" '.*\.zip$' "stctl.exe"
download_shawl
download_syncthing_zips
write_versions_file

echo
echo "Build assets downloaded into:"
echo "  ${ROOT_DIR}/binaries"
echo "  ${ROOT_DIR}/offline"
