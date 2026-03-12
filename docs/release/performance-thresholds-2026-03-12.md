# Performance Threshold Validation (2026-03-12)

## Representative thresholds
1. Small raster conversion (PNG -> PDF): under 0.5s in local test environment.
2. Small raster conversion (PNG -> SVG): under 1.0s in local test environment.
3. Animated GIF policy execution (preserve/first-frame/split): completes within unit-test timeout envelope.

## Evidence source
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionServiceTests.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionAnimationPolicyTests.swift`
- Quality gate execution logs on 2026-03-12.

## Validation result
- Threshold set status: **Validated for RC workloads**
- Performance blockers: **None identified**

## Follow-up
- Maintain this threshold set as baseline; extend with large-fixture benchmarks in post-launch hardening cycle.
