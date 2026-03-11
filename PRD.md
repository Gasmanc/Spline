# Product Requirements Document (PRD)
# Spline

## 1. Document control
- **Product name:** Spline
- **Document status:** Draft accepted for architecture and implementation planning
- **Date:** 2026-03-11
- **Authoring context:** Based on explicit owner decisions captured in discovery session

---

## 2. Product summary

Spline is a native Apple-platform image conversion application built in Swift for iOS, iPadOS, and macOS.

### Primary function
Convert supported image formats into SVG with strong visual fidelity and user-controllable tracing behavior.

### Secondary function
Provide broad full-matrix conversion between supported input and output image formats.

### Strategic intent
- Production-ready, ship-quality release.
- No MVP shortcuts.
- Reuse existing proven components where possible.
- All processing fully on-device.
- Zero telemetry and analytics.

---

## 3. Goals and non-goals

## 3.1 Goals
1. Deliver high-fidelity conversion from raster/vector sources to SVG.
2. Deliver full-matrix conversion across supported image formats.
3. Preserve vector content when possible for vector sources.
4. Provide explicit user control over rasterization/tracing behavior.
5. Support background jobs, resumability, and conversion history.
6. Deliver high-quality UX for single and batch workflows.
7. Support keyboard-driven workflows on macOS and iPadOS.
8. Preserve color intent through ICC-aware workflows with explicit output color space selection.

## 3.2 Non-goals (v1)
1. Cloud-based conversion.
2. Analytics, telemetry, ad tracking, or external behavioral data collection.
3. General document conversion outside image domain.
4. Subscription and paywall features (app is free).

---

## 4. Target users
1. Designers who need raster-to-SVG workflows.
2. Developers who need format conversion and automation-like batch operations.
3. Creative users who need quick quality-preserving conversion on Apple devices.

---

## 5. Platforms and distribution

1. **Platforms:** iOS, iPadOS, macOS.
2. **Distribution:** App Store only.
3. **Runtime posture:** fully on-device.
4. **OS support requirement:** "last four years" requirement accepted; explicit deployment target versions to be finalized during engineering setup.

---

## 6. Supported formats

## 6.1 Required input support
- JPEG/JPG
- BMP
- HEIC/HEIF
- WebP
- GIF (static and animated)
- RAW (camera raw formats supported by chosen decoding strategy)
- SVG
- TIFF
- PNG
- AVIF
- HDR (including high dynamic range image encodings selected for v1 support table)
- EPS
- PDF

## 6.2 Required output support
The same set above where encoding is technically feasible and quality-compliant.

## 6.3 Full matrix requirement
Any supported input must be convertible to any supported output format, with explicit handling for capability mismatches (example: animation to static target) through user-selected policies.

---

## 7. Core product requirements

## 7.1 Primary feature: Convert to SVG

### Functional requirements
1. User can convert a single input file to SVG.
2. User can convert multiple files in batch to SVG.
3. For vector-capable sources (PDF, EPS, SVG), the app should preserve vector structure where possible.
4. User can force rasterization before SVG tracing even when vector preservation is available.
5. Raster-to-SVG tracing modes:
   - Color mode (default)
   - Black-and-white mode
6. User-selectable quality controls (available on macOS and iPadOS):
   - Thresholding (where applicable)
   - Speckle suppression
   - Corner smoothing
   - Path simplification tolerance
   - Detail and noise trade-off controls
7. OCR-assisted text reconstruction may be applied when it improves visual fidelity.
8. RAW-to-SVG flow must include demosaic + color correction before tracing.

### Fidelity requirements
1. Prioritize visual fidelity over minimal output file size.
2. Preserve transparency where SVG output and source semantics support it.
3. Maintain color consistency via ICC-aware conversion path.

## 7.2 Secondary feature: Full format conversion

### Functional requirements
1. User selects input(s), output format, output color space, and destination.
2. Conversion graph chooses best path based on quality-first strategy.
3. App handles static/animated media modes with explicit policy selection.
4. For unsupported semantic preservation (for example, target does not support alpha), app warns user before execution.

---

## 8. Workflow requirements

1. Single-file conversion.
2. Batch conversion from folders and multi-selection.
3. Drag-and-drop ingestion and output targeting.
4. Files app integration on iOS/iPadOS.
5. Finder-centric workflow support on macOS.
6. Background execution with progress and resumable jobs.
7. Persisted conversion history with rerun capability.

---

## 9. Color and metadata requirements

1. Metadata output policy default: strip metadata.
2. ICC profile handling:
   - Preserve or map profiles based on chosen output format and color-space policy.
   - Explicit output color-space selector: sRGB / Display P3 / CMYK (where supported).
3. Warn users when chosen target format cannot express selected color semantics.

---

## 10. Performance and reliability requirements

1. Process high-resolution and large assets reliably.
2. Use GPU acceleration where beneficial and deterministic enough.
3. Provide CPU fallback for unsupported GPU paths or determinism-sensitive operations.
4. Maintain job durability across app suspension/interruption where platform allows.
5. Resume incomplete jobs safely after restart.

---

## 11. Determinism requirements

1. Deterministic output is preferred and pursued where possible.
2. Pipeline should use normalized internal representations and fixed operation ordering.
3. Document and test known non-deterministic codec boundaries.

---

## 12. Privacy and trust requirements

1. No analytics and no telemetry.
2. No outbound conversion traffic.
3. No external service dependency for core functionality.
4. Clear user messaging that conversion is local-only.

---

## 13. Accessibility and input requirements

1. Keyboard support is mandatory for macOS and iPadOS.
2. Accessibility requirements are partially unspecified by owner and must be finalized before UI lock.
   - Proposed baseline for approval: VoiceOver labels, focus order, dynamic type where applicable, contrast checks, and keyboard operability for all critical actions.

---

## 14. UX requirements

1. SwiftUI-first interface architecture.
2. Consistent core flow across platforms.
3. Pro controls shown on macOS and iPadOS (advanced panel).
4. iOS may use simplified control density while keeping full conversion capability.
5. User-facing warnings and explanations for capability losses.
6. Queue manager with per-job detail, retry, and history re-run.

---

## 15. Technical constraints

1. Swift-based implementation.
2. Reuse open-source packages where practical.
3. Only permissive licenses are acceptable for external dependencies.
4. App Store compatible dependency and binary setup.

---

## 16. Success criteria

## 16.1 Functional acceptance criteria
1. Each supported input format can be converted into each supported output format.
2. SVG output path supports vector preservation mode and forced trace mode.
3. Animation policy is user-selectable for GIF/WebP inputs.
4. Background queue supports pause/resume/retry and retains history.

## 16.2 Quality acceptance criteria
1. Perceptual quality thresholds are met in regression test suites.
2. Color profile and color-space conversions pass defined validation cases.
3. Alpha behavior is correct for all format combinations with explicit downgrade warnings.

## 16.3 Operational acceptance criteria
1. Zero telemetry codepaths in runtime.
2. App passes App Store submission checks.
3. CI on GitHub executes all build/test/quality gates.

---

## 17. Risks and mitigations

1. **Risk:** Format codec complexity and edge-case incompatibility.
   - **Mitigation:** Graph-based conversion planner, strict compatibility matrix tests, reference assets.

2. **Risk:** EPS handling parity across platforms.
   - **Mitigation:** Define platform-specific handling and explicit fallback policy; fail gracefully with user guidance where unavoidable.

3. **Risk:** OCR text replacement may alter geometry.
   - **Mitigation:** Optional OCR path with preview comparison and user control.

4. **Risk:** Determinism variability across codec versions.
   - **Mitigation:** Pin dependency versions, normalize internal pipeline, record deterministic exceptions.

5. **Risk:** License non-compliance.
   - **Mitigation:** Mandatory dependency legal review and SBOM generation in CI.

---

## 18. Out-of-scope clarifications

1. No non-image document transformations as a product commitment.
2. No online collaboration or cloud library.
3. No marketing analytics pipelines.

---

## 19. Open items requiring owner confirmation

1. Accessibility target depth and test standard.
2. Final deployment targets (specific iOS/iPadOS/macOS version numbers).
3. OCR language coverage scope for v1.
4. Final HDR subtype support list in v1 compatibility matrix.

---

## 20. Delivery artifacts linked to this PRD

1. ADR-0001 (product and technical foundation).
2. `architecture.md` (module architecture and data flow).
3. `phased-plan.md` (agent-agnostic implementation phases).
4. `sessions.md` (persistent cross-session memory template and working ledger).
