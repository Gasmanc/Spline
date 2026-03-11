# Contributing to Spline

## Local setup
1. Install latest Xcode stable with command line tools.
2. Install SwiftLint (`brew install swiftlint`).
3. Install Node.js 22+.
4. Clone repository and run baseline checks.

## Baseline commands
1. `node scripts/verify-dependencies.mjs`
2. `bash scripts/generate-sbom.sh`
3. `for pkg in Packages/*; do (cd "$pkg" && swift test); done`
4. `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`

## Workflow
1. Pick task mapped to phase package.
2. Implement with tests.
3. Update docs and `sessions.md`.
4. Open pull request using template.
