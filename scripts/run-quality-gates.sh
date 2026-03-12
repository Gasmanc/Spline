#!/usr/bin/env bash
set -euo pipefail

swiftlint --strict

for pkg in Packages/*; do
  if [ -f "$pkg/Package.swift" ]; then
    (cd "$pkg" && swift test)
  fi
done

find Packages -type d -name .build -prune -exec rm -rf {} +
node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs
