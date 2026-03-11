# Spline Architecture

## 1. Architectural principles

1. SwiftUI-first, native Apple platform implementation.
2. Modular boundaries to isolate codec, conversion, and UI complexity.
3. Reuse-first: Apple frameworks first, OSS where necessary.
4. Fully on-device pipeline.
5. Quality-first conversion with explicit user controls.
6. Fail-safe and resumable job execution.

---

## 2. High-level architecture

## 2.1 Runtime layers

1. **Presentation Layer**
   - SwiftUI views and platform adapters.
   - Input workflows: Files picker, drag/drop, folder ingestion.

2. **Application Layer**
   - Use cases and orchestration.
   - Job scheduling and lifecycle management.

3. **Domain Layer**
   - Conversion intent model.
   - Format capabilities.
   - Planning policies (fidelity-first, deterministic-preferred).

4. **Engine Layer**
   - Decode/encode services.
   - Intermediate frame model.
   - Vectorization and OCR integration.
   - Color management.

5. **Infrastructure Layer**
   - File access/bookmarks/sandbox handling.
   - Persistent storage for jobs/history.
   - Dependency wrappers and native C/C++/Rust bridges.

---

## 3. Final architecture modules and services

## 3.1 Modules

1. `SplineAppiOS` / `SplineAppmacOS`
   - Platform targets, entitlements, scene setup.

2. `SplineUI`
   - Shared SwiftUI components, keyboard commands, drag-drop UI.

3. `SplineApplication`
   - Use cases:
     - `CreateConversionJobUseCase`
     - `PlanConversionUseCase`
     - `ExecuteJobUseCase`
     - `ResumeInterruptedJobsUseCase`
     - `ReRunHistoryItemUseCase`

4. `SplineDomain`
   - Core types:
     - `ImageFormat`
     - `ColorProfilePolicy`
     - `OutputColorSpace`
     - `AnimationPolicy`
     - `ConversionIntent`
     - `ConversionPlan`
     - `JobState`
   - Rule engine for compatibility and downgrade warnings.

5. `SplineConversionEngine`
   - Decoder/Encoder registry.
   - Graph planner and path scoring.
   - Intermediate image representation.

6. `SplineVectorization`
   - Vector preservation pipeline.
   - Raster trace pipeline.
   - OCR-assisted text reconstruction pipeline.

7. `SplineColor`
   - ICC profile retention/transform.
   - Explicit output color-space conversion.

8. `SplineJobs`
   - Background queue.
   - Durable checkpoints.
   - Retry, pause, resume.

9. `SplineStorage`
   - Sandbox-safe file system abstraction.
   - Temporary file lifecycle.
   - History persistence and cleanup.

10. `SplineTestingAssets`
    - Golden files and regression fixtures.

## 3.2 Key services

1. `FormatCapabilityService`
2. `ConversionGraphService`
3. `PlanScoringService`
4. `DecoderService`
5. `EncoderService`
6. `VectorPreservationService`
7. `RasterTracingService`
8. `OCRTextLayerService`
9. `ColorTransformService`
10. `JobCheckpointService`
11. `HistoryService`
12. `DeterminismValidationService`

---

## 4. Conversion engine strategy

## 4.1 Core model

Use a directed conversion graph:
- Node = canonical format representation.
- Edge = concrete transform (decode, normalize, color transform, vectorize, encode).
- Planner = weighted shortest path with hard constraints.

Hard constraints include:
- Target format capability support.
- Animation retention policy.
- Alpha support requirements.
- Color-space support and profile policy.

Soft constraints include:
- Visual fidelity score (highest priority).
- Determinism score.
- Runtime cost score.

## 4.2 Internal canonical representations

1. `RasterFrame` and `AnimatedRasterSequence` for static/animated raster.
2. `VectorDocument` for SVG/PDF/EPS vector-preserving path.
3. `ColorManagedImage` wrapper requiring explicit profile annotation.

## 4.3 SVG path strategy

### Path A: Vector-preserving
1. Parse source vector document.
2. Preserve geometry where possible.
3. Normalize transforms, clipping, and paint models.
4. Emit SVG with quality checks.

### Path B: Raster-trace
1. Decode to raster frame(s).
2. RAW-specific pre-processing: demosaic + camera-aware correction.
3. Apply user-selected pre-trace normalization.
4. Trace in selected mode (color or B/W).
5. Optional OCR text replacement for fidelity.
6. Emit SVG and run post-simplification guardrails.

### User controls
- Force Path B for any source.
- Mac/iPad advanced controls for threshold/speckle/smoothing/simplification.

## 4.4 Animation strategy

Inputs with animation support (GIF/WebP and others where supported):
- Policies:
  1. First frame only
  2. Preserve animation when target supports animation
  3. Split to frame sequence outputs

## 4.5 Determinism strategy

1. Fixed operation ordering.
2. Fixed precision and rounding policies.
3. Normalized metadata stripping behavior.
4. Determinism tests with checksum/perceptual dual checks.

---

## 5. Exact package and tooling choices (with license rationale)

> Note: final lock requires automated license verification and App Store compliance checks in CI before dependency freeze.

## 5.1 Apple frameworks (primary)

1. **SwiftUI** (UI)
2. **CoreGraphics / ImageIO** (image I/O and format support baseline)
3. **CoreImage** (image processing, RAW processing pathways)
4. **PDFKit / Quartz** (PDF and vector-adjacent workflows)
5. **Vision** (OCR when selected)
6. **UniformTypeIdentifiers** (format detection)
7. **BackgroundTasks** / platform equivalents (job continuation where supported)

License rationale: Apple platform SDK components; no third-party license risk.

## 5.2 Open source package candidates selected for evaluation and integration

1. **libwebp** (BSD-3-Clause)
   - Purpose: robust WebP decode/encode, including animated assets.
   - Rationale: permissive license, mature ecosystem.

2. **libavif** (BSD-2-Clause)
   - Purpose: AVIF decode/encode support beyond baseline OS capability variance.
   - Rationale: permissive, production-proven.

3. **vImage / Accelerate usage (Apple)**
   - Purpose: high-performance pixel transforms and fallback-safe deterministic operations.
   - Rationale: first-party performance path.

4. **Vectorization engine candidate: vtracer bridge (MIT/Apache-style permissive expected, license verification required before lock)**
   - Purpose: color-capable raster-to-vector tracing pipeline.
   - Rationale: avoids GPL constraints associated with Potrace.
   - Gate: exact repository license must be verified and recorded before adoption.

5. **SVG handling candidate: Swift native parser/writer with permissive license (candidate shortlist to be verified in Phase 1 legal gate)**
   - Purpose: robust SVG parse/write and normalization.
   - Rationale: avoid bespoke parser implementation.

6. **EPS strategy**
   - Primary: Apple/Quartz pathway where available.
   - Fallback: permissive dependency only if required; AGPL/GPL options rejected.

## 5.3 Rejected dependency classes

1. GPL/AGPL conversion engines in app runtime distribution.
2. Any dependency requiring non-permissive reciprocal licensing for app code.

## 5.4 Tooling stack

1. Xcode + Swift Package Manager
2. GitHub Actions for CI
3. SwiftLint and SwiftFormat (or equivalent formatting/lint tooling)
4. License scanning in CI (SPDX/SBOM generation)
5. Snapshot/golden-image regression framework

---

## 6. Data and state design

## 6.1 Job entity

- `jobId`
- `createdAt`, `updatedAt`
- `inputURLs`
- `outputFormat`
- `outputColorSpace`
- `traceMode`
- `advancedParameters`
- `animationPolicy`
- `status`
- `progress`
- `checkpoint`
- `errorInfo`

## 6.2 History entity

- Immutable record of completed/failed jobs.
- Includes reproducibility metadata:
  - pipeline version
  - dependency versions
  - deterministic flags

---

## 7. Testing and QA matrix

## 7.1 Unit testing
1. Format capability resolution.
2. Graph planner correctness.
3. Path scoring fidelity priorities.
4. Metadata stripping behavior.
5. Color-space conversion rules.

## 7.2 Integration testing
1. Decode/encode round trips by format.
2. Cross-format matrix smoke tests.
3. SVG vector preservation pipeline.
4. Raster tracing pipeline with control combinations.
5. OCR insertion correctness boundaries.

## 7.3 Golden-image and perceptual testing
1. Canonical fixtures for each source format category.
2. Perceptual diff thresholds (SSIM/PSNR/perceptual hash strategy as selected).
3. Visual fidelity assertions prioritized over binary equality where codecs are not byte-deterministic.

## 7.4 Determinism testing
1. Re-run same job N times on same device/os build.
2. Compare output checksums where deterministic expected.
3. Use perceptual fallback checks where codec implementation variance is unavoidable.

## 7.5 Performance testing
1. Large file set benchmarks.
2. Batch throughput tests.
3. Memory pressure and thermal resilience tests.
4. GPU path vs CPU fallback consistency tests.

## 7.6 Platform UX testing
1. iOS/iPadOS Files integration.
2. macOS Finder drag-drop and keyboard command flows.
3. Queue, pause/resume, restart recovery.

## 7.7 Release qualification gates
1. Full matrix conversion pass rate threshold.
2. No crash in soak tests.
3. App startup and first conversion latency target met.
4. No telemetry network emissions verified.

---

## 8. App Store readiness checklist

1. App privacy answers reflect zero data collection.
2. No analytics SDKs present.
3. Export compliance reviewed for included codecs.
4. Third-party notices and attribution bundled.
5. Permissions minimized and justified.
6. Crash-free and memory stability acceptance met.
7. Metadata/screenshots prepared for all required device classes.
8. Accessibility baseline completed (once finalized).
9. License compliance report generated and archived.
10. TestFlight validation cycle complete.

---

## 9. Observability without telemetry

1. Local-only diagnostic logs with explicit user export action.
2. No remote upload path.
3. Redacted error details for safe support sharing.

---

## 10. Open architecture questions

1. Exact OCR language packs for v1.
2. EPS fidelity parity details on iOS/iPadOS.
3. Final dependency lock for vector tracing and SVG parser after legal verification.
4. Accessibility depth final decision.
