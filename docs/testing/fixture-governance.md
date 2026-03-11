# Test Fixture and Golden Asset Governance

## Purpose
Ensure conversion quality testing remains repeatable, versioned, and auditable.

## Rules
1. Fixtures must be legally redistributable.
2. Each fixture must include provenance metadata (source, license, date acquired).
3. Golden outputs are versioned by pipeline version.
4. Any golden update requires rationale and before/after diff evidence.
5. Large binary fixtures should be stored via approved large file strategy.

## Directory convention
- `Packages/SplineTestingAssets/fixtures/<format>/<name>`
- `Packages/SplineTestingAssets/golden/<pipeline-version>/<test-case>`
- `Packages/SplineTestingAssets/manifest.json`

## Required manifest fields
- fixtureId
- sourceFormat
- sourceLicense
- expectedCapabilities
- sensitiveContentFlag
- lastValidatedAt
