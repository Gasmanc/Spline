# Repository Governance

## Branch protection policy
Apply to `main`:
1. Require pull request before merging.
2. Require at least one approval.
3. Require status checks to pass:
   - `lint-and-policy`
   - `build-packages`
4. Require branch up to date before merge.
5. Dismiss stale approvals on new commits.
6. Restrict force pushes and direct pushes.

## Pull request requirements
1. Link to issue or phase task.
2. Include test evidence for behavior changes.
3. Include screenshot/video for UI changes.
4. Update docs/ADR/sessions where applicable.
5. Confirm dependency and license review for new third-party additions.

## Release governance
1. Release tags follow semantic versioning.
2. Release candidate requires Phase 7 sign-off artifacts.
3. Production release requires Phase 8 checklist completion.
