#!/usr/bin/env bash
# Official immutable-by-digest snapshot, retrieved 2026-10-14.
set -euo pipefail
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'This pinned installer supports Linux x86_64 only.' >&2; exit 1
fi
export MOON_HOME="${MOON_HOME:-$HOME/.moonbelief-toolchain}"
mkdir -p "$MOON_HOME/lib"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
curl --fail --location --retry 2 --header 'If-Match: "6ae7c52851085cc3d4d65fd04410ef7b-12"' \
  https://cli.moonbitlang.com/binaries/latest/moonbit-linux-x86_64.tar.gz -o "$work/moon.tar.gz"
curl --fail --location --retry 2 --header 'If-Match: "65ef1811c0e64c48bf01312100f7e998"' \
  https://cli.moonbitlang.com/cores/core-latest.tar.gz -o "$work/core.tar.gz"
(cd "$work" && printf '%s\n' \
  '24b93a5409d2a4fb8e3d1b84b473f27b63476cef4418094764df96cb26b03c09  moon.tar.gz' \
  '96d30f4dbcc6a9e1736ef26fbdd0e8fb0e97cb01d50e55d2a0072208b8061ae5  core.tar.gz' | sha256sum --check -)
tar -xzf "$work/moon.tar.gz" -C "$MOON_HOME"
tar -xzf "$work/core.tar.gz" -C "$MOON_HOME/lib"
chmod +x "$MOON_HOME/bin/"*
export PATH="$MOON_HOME/bin:$PATH"
moon version --all
moon -C "$MOON_HOME/lib/core" bundle --warn-list -a --all
if [[ -n "${GITHUB_PATH:-}" ]]; then printf '%s\n' "$MOON_HOME/bin" >> "$GITHUB_PATH"; fi
if [[ -n "${GITHUB_ENV:-}" ]]; then printf 'MOON_HOME=%s\n' "$MOON_HOME" >> "$GITHUB_ENV"; fi
