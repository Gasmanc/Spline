# ADR-0001: Spline Product and Technical Foundation

- **Status:** Accepted
- **Date:** 2026-03-11
- **Decision Makers:** Product Owner, Engineering
- **Scope:** iOS, iPadOS, macOS application named **Spline**

## Context

Spline is a ship-ready Apple-platform image conversion application.

Primary objective:
- Convert supported raster/vector image inputs to high-fidelity SVG output.

Secondary objective:
- Convert from any supported input image format to any supported output image format (full matrix), subject to fundamental target format capability limits.

User requirements and constraints:
1. Platforms: iOS, iPadOS, macOS.
2. Framework direction: SwiftUI-first architecture.
3. Conversion support targets include: JPEG, BMP, HEIC, WebP, GIF, RAW, SVG, TIFF, PNG, AVIF, HDR, EPS, and PDF.
4. SVG conversion:
   - Preserve vectors when possible (especially PDF/EPS/SVG sources), with a user option to force rasterization and trace.
   - Color tracing should be user-selectable and default mode.
   - Black-and-white mode should be selectable.
   - Visual fidelity is higher priority than smallest file size.
5. GIF/WebP animation handling must be user-selectable.
6. Advanced tracing controls are required on iPadOS and macOS.
7. OCR-to-SVG-text may be used if it gives better visual fidelity.
8. RAW to SVG requires demosaic and color correction before vectorization.
9. Preserve alpha/transparency where supported.
10. Metadata default policy: strip metadata.
11. Color management:
    - ICC profile preservation support.
    - Explicit output color space selection (sRGB/P3/CMYK where possible).
12. User workflows: single-file, batch folder conversion, drag-and-drop, Files integration on iOS/iPadOS, Finder workflows on macOS.
13. Processing: fully on-device, no cloud dependency.
14. Performance: use GPU acceleration when beneficial, with CPU fallback.
15. Jobs: background processing, resumable jobs, and conversion history.
16. Deterministic outputs: preferred where possible.
17. Open-source policy: reuse existing packages; permissive licenses required.
18. Distribution: App Store only.
19. Business model: free application.
20. Privacy/analytics: zero telemetry/analytics.
21. Accessibility detail was not fully specified by product owner and remains an explicit open decision.
22. CI: GitHub-based.
23. Keyboard support required on macOS and iPadOS.

## Decision

### D1. Architecture style
Adopt a modular Swift Package architecture with a thin app shell per platform:
- `SplineApp` (SwiftUI app targets: iOS, iPadOS, macOS)
- `SplineDomain` (entities, use cases, policies)
- `SplineConversionEngine` (format decoding/encoding, graph planner, transformations)
- `SplineVectorization` (raster-to-vector, vector preservation orchestration, OCR hooks)
- `SplineColor` (ICC profiles, color transforms, output color-space mapping)
- `SplineJobs` (background queue, resumable state machine, history)
- `SplineStorage` (sandbox-safe file access, bookmarks, temp/output lifecycle)
- `SplineUIComponents` (cross-platform SwiftUI components + platform-specific bridges)

### D2. Conversion model
Use a graph-based conversion engine rather than hard-coding pairwise converters:
- Represent each format as a node and each converter as a directed edge.
- Build conversion plans by pathfinding with weighted priorities for fidelity, speed, and determinism.
- This supports full matrix expansion without exponential code duplication.

### D3. Primary SVG strategy
Use a two-path SVG generation model:
1. **Vector-preserving path** for vector-capable inputs (PDF, EPS where parse/render path can preserve vector, SVG).
2. **Raster-to-vector path** for raster inputs or forced-raster mode.

User can explicitly choose mode where both are possible.

### D4. Package and dependency policy
Use Apple frameworks first, then permissive licensed OSS packages where system support is incomplete.

License gate:
- Every dependency must be validated as permissive and App Store compatible before lock.
- Non-permissive dependency proposals are rejected.

### D5. Privacy and security posture
- Fully on-device processing.
- No analytics, no telemetry, no external processing APIs.
- Metadata stripped by default from outputs.

### D6. UX and workflow posture
- Unified SwiftUI-first UX.
- Desktop/iPad pro controls for advanced tracing parameters.
- Keyboard-first support on macOS and iPadOS.
- Batch and background workflows are first-class, not post-v1 additions.

### D7. Quality and release bar
- Ship-ready quality target from initial release line.
- Deterministic outputs pursued where feasible and measured.
- Golden-image and perceptual quality regression testing required.
- CI and release automation in GitHub workflows.

## Consequences

### Positive
- Scales to full matrix format conversion without duplicated bespoke pipelines.
- Maintains maintainability and testability through explicit module boundaries.
- Reduces legal/App Store risk via explicit permissive license gate.
- Aligns with user requirement for production quality and no MVP compromise.

### Trade-offs
- Upfront architecture and infra cost is higher.
- EPS and advanced vector preservation paths may require platform-specific handling and careful fallback strategy.
- Deterministic output across heterogeneous codec implementations may require strict normalization and may still have edge variance.

## Open decisions requiring explicit follow-up

Resolved by `docs/adr/ADR-0002-v1-product-decisions-and-eps-parity-contract.md`:

1. Accessibility baseline depth.
2. OCR language/script scope for v1.
3. EPS parity contract on iOS/iPadOS/macOS.
4. Exact minimum OS deployment targets.

## Validation criteria

This ADR is considered correctly implemented when:
- The codebase matches the modular boundaries in D1.
- Conversion is driven by graph planning (D2).
- SVG conversion uses dual-path strategy with explicit user control (D3).
- Dependency lock includes license evidence for each external package (D4).
- No telemetry pathways exist in runtime (D5).
- Batch/background/history workflows and keyboard support are available in production (D6).
- CI includes quality gates and regression testing (D7).
