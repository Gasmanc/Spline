# App Store Submission Runbook

## Objective
Provide repeatable release operations for TestFlight and App Store submission.

## Pre-submit gates
1. Run `scripts/run-quality-gates.sh` and store logs.
2. Confirm dependency notices are up to date in `THIRD_PARTY_NOTICES.md`.
3. Confirm `DEPENDENCIES.md` and `dependency-report.json` match repository state.
4. Confirm `docs/repo-governance.md` branch policy remains active.

## Build and signing
1. Archive iOS and macOS targets with release configuration.
2. Validate entitlements are minimal and expected.
3. Validate no non-production debug flags are enabled.

## Privacy and compliance
1. App Privacy questionnaire remains zero data collection.
2. Confirm no telemetry SDK linked artifacts exist.
3. Verify export compliance declarations for shipped codecs.

## Submission assets
1. Screenshots for required device families.
2. App metadata and description accuracy.
3. Version notes and known limitations.

## Post-submit operations
1. Monitor review outcomes.
2. Triage review feedback and submit targeted patch if required.
3. Record release evidence references in `sessions.md`.
