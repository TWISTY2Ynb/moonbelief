#!/usr/bin/env bash
# Official immutable-by-digest snapshot, retrieved 2026-11-01.
set -euo pipefail
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'This pinned installer supports Linux x86_64 only.' >&2; exit 1
fi
export MOON_HOME="${MOON_HOME:-$HOME/.moonbelief-toolchain}"
mkdir -p "$MOON_HOME/lib"
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
curl --fail --location --retry 2 --header 'If-Match: "0560ebd5ba5528390cd4872766f2234b"' \
  https://cli.moonbitlang.com/binaries/latest/moonbit-linux-x86_64.tar.gz -o "$work/moon.tar.gz"
curl --fail --location --retry 2 --header 'If-Match: "7b87b77b0d942a76fba657b809c31cdf"' \
  https://cli.moonbitlang.com/cores/core-latest.tar.gz -o "$work/core.tar.gz"
(cd "$work" && printf '%s\n' \
  '0e4cde1ace98e8ef00552a937738b59c6901c4b8a004ebad71ea0e63688f63f1  moon.tar.gz' \
  '30a8ae1c1e1e8fde478ea742cbc928c8f4ae1f5c00090afe3f10c97be9e5da64  core.tar.gz' | sha256sum --check -)
tar -xzf "$work/moon.tar.gz" -C "$MOON_HOME"
tar -xzf "$work/core.tar.gz" -C "$MOON_HOME/lib"
chmod +x "$MOON_HOME/bin/"*
export PATH="$MOON_HOME/bin:$PATH"
moon version --all
python scripts/check_toolchain.py
moon -C "$MOON_HOME/lib/core" bundle --warn-list -a --all
if [[ -n "${GITHUB_PATH:-}" ]]; then printf '%s\n' "$MOON_HOME/bin" >> "$GITHUB_PATH"; fi
if [[ -n "${GITHUB_ENV:-}" ]]; then printf 'MOON_HOME=%s\n' "$MOON_HOME" >> "$GITHUB_ENV"; fi
