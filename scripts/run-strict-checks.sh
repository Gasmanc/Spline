#!/usr/bin/env bash
set -euo pipefail

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint --strict
else
  echo "swiftlint not installed; skipping lint command in local run"
fi

for pkg in Packages/*; do
  if [ -f "$pkg/Package.swift" ]; then
    (cd "$pkg" && swift test)
  fi
done
