# Spline Sessions Memory Ledger

This document is a persistent cross-session working memory for human and AI contributors.
It is designed to preserve continuity, decisions, pending questions, and operational context.

## Usage rules

1. Every meaningful work session appends a new session entry.
2. Do not rewrite history entries; append corrections as new entries.
3. Decisions become authoritative only when linked to an ADR or explicit owner confirmation.
4. Open questions must carry an owner and target decision date.
5. Keep implementation references concrete (file paths, branch names, pull requests, test runs).

---

## Project identity snapshot

- **Project:** Spline
- **Type:** SwiftUI-first iOS/iPadOS/macOS image conversion app
- **Primary function:** Convert supported formats to SVG with high fidelity and configurable tracing
- **Secondary function:** Full matrix conversion among supported image formats
- **Privacy:** On-device only, zero analytics/telemetry
- **Distribution:** App Store only, free app

---

## Current accepted decisions (summary)

1. Full matrix conversion across supported image formats.
2. SVG conversion supports vector-preserving path and forced raster-trace path.
3. Color tracing is default; black-and-white tracing also available.
4. Advanced tracing controls required on macOS and iPadOS.
5. Metadata stripped by default.
6. ICC profile-aware color workflow with explicit output color-space selection.
7. Background resumable jobs and history are in-scope.
8. Keyboard support required on macOS and iPadOS.

Authoritative source:
- `docs/adr/ADR-0001-spline-product-and-technical-foundation.md`
- `docs/adr/ADR-0002-v1-product-decisions-and-eps-parity-contract.md`

---

## Open decisions register

| ID | Topic | Question | Owner | Due Date | Status |
|----|-------|----------|-------|----------|--------|
| O-001 | Accessibility depth | What is the final accessibility acceptance baseline for v1? | Product Owner | 2026-03-18 | Resolved (ADR-0002, 2026-03-12) |
| O-002 | Deployment targets | Exact iOS/iPadOS/macOS minimum version numbers from "last 4 years" rule | Engineering + Product | 2026-03-14 | Resolved (ADR-0002, 2026-03-12) |
| O-003 | OCR scope | Which OCR languages and scripts are required in v1? | Product Owner | 2026-03-20 | Resolved (ADR-0002, 2026-03-12) |
| O-004 | EPS parity | Final behavior matrix for EPS across iOS/iPadOS/macOS | Engineering | 2026-03-21 | Resolved (ADR-0002, 2026-03-12) |

Resolution source:
- `docs/adr/ADR-0002-v1-product-decisions-and-eps-parity-contract.md`

---

## Dependency decision log

| Date | Dependency | Intended Use | License | Decision | Notes |
|------|------------|--------------|---------|----------|-------|
| 2026-03-11 | libwebp | WebP decode/encode | BSD-3-Clause | Locked | Integrated via `CWebPBridge` |
| 2026-03-11 | libavif | AVIF decode/encode | BSD-2-Clause | Locked | Integrated via `CAVIFBridge` |
| 2026-03-12 | vtracer | Color-capable raster-to-vector | MIT OR Apache-2.0 | Locked | Integrated via `ExternalVTracerService` |

---

## Session entry template

```markdown
## Session YYYY-MM-DD HH:MM TZ

### Participants
- Human:
- Agent:

### Objectives
1.
2.

### Actions performed
1.
2.

### Decisions made
1.

### Files changed
- path/to/file.md

### Tests / verification
- Command:
- Result:

### Risks found
1.

### Open questions created or updated
- O-XXX:

### Next recommended actions
1.
2.
```

---

## Session history

## Session 2026-03-11 19:11 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Capture explicit product requirements for ship-ready planning.
2. Produce foundational planning artifacts.

### Actions performed
1. Collected requirement clarifications and constraints.
2. Authored ADR, PRD, architecture document, phased implementation plan, and this persistent memory ledger.

### Decisions made
1. Core product direction and technical posture accepted and recorded in ADR-0001.

### Files changed
- `docs/adr/ADR-0001-spline-product-and-technical-foundation.md`
- `PRD.md`
- `architecture.md`
- `phased-plan.md`
- `sessions.md`

### Tests / verification
- No production code changes in this session.

### Risks found
1. Accessibility scope not yet finalized.
2. Some dependency licenses require formal lock-time verification.

### Open questions created or updated
- O-001, O-002, O-003, O-004

### Next recommended actions
1. Resolve open decisions and update ADR if needed.
2. Execute Phase 0 and Phase 1 tasks in `phased-plan.md`.

## Session 2026-03-11 21:10 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Create execution packages for all phases.
2. Commence Phase 0 with concrete repository setup and governance artifacts.

### Actions performed
1. Created phase execution packages for Phases 0 through 8 under `execution-packages/`.
2. Created initial repository scaffolding for app and package module structure.
3. Added Swift package manifests and baseline source/test targets for architecture modules.
4. Added engineering standards, lint configuration, dependency policy, SBOM script, and CI workflow.
5. Added testing fixture governance documentation.
6. Updated open decision register with owners and due dates.
7. Ran local verification commands and zero-debt gate.

### Decisions made
1. Phase 0 commenced with baseline scaffolding completed.
2. Dependency policy enforcement begins in Phase 0 using local script plus CI step.

### Files changed
- `execution-packages/README.md`
- `execution-packages/phase-0-foundation-readiness/package.md`
- `execution-packages/phase-1-dependency-legal-lock/package.md`
- `execution-packages/phase-2-domain-graph-engine/package.md`
- `execution-packages/phase-3-decode-encode-pipeline/package.md`
- `execution-packages/phase-4-svg-primary-pipeline/package.md`
- `execution-packages/phase-5-jobs-background-history/package.md`
- `execution-packages/phase-6-ux-platform-integration/package.md`
- `execution-packages/phase-7-quality-hardening/package.md`
- `execution-packages/phase-8-app-store-launch/package.md`
- `Apps/README.md`
- `Packages/*/Package.swift`
- `Packages/*/Sources/*/*.swift`
- `Packages/*/Tests/*/*.swift`
- `CODE_STANDARDS.md`
- `.swiftlint.yml`
- `.github/workflows/ci.yml`
- `config/dependency-policy.json`
- `scripts/verify-dependencies.mjs`
- `scripts/generate-sbom.sh`
- `docs/testing/fixture-governance.md`
- `docs/repo-governance.md`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/regression_report.yml`
- `.github/PULL_REQUEST_TEMPLATE/default.md`
- `CONTRIBUTING.md`
- `debt-exceptions.yaml`

### Tests / verification
- Command: `node scripts/verify-dependencies.mjs`
- Result: Pass (no locked dependency report yet)
- Command: `bash scripts/generate-sbom.sh`
- Result: Pass (`artifacts/sbom.json` created)
- Command: `for pkg in Packages/*; do (cd "$pkg" && swift test); done`
- Result: Pass across all scaffolded packages
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. App targets are currently directory scaffolds; Xcode app target generation remains pending deployment target finalization.
2. Dependency inventory report generation (`dependency-report.json`) must be implemented in Phase 1.

### Open questions created or updated
- O-001, O-002, O-003, O-004 due dates assigned.

### Next recommended actions
1. Apply documented branch protection settings in GitHub repository configuration.
2. Begin Phase 1 dependency candidate lock and legal validation workflow.

## Session 2026-03-12 15:25 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Integrate approved permissive external codec and tracing dependencies.
2. Keep strict lint, test, and zero-debt compliance.

### Actions performed
1. Installed and integrated `libwebp` and `libavif` through C bridge targets in `SplineConversionEngine`.
2. Implemented external codec Swift bridge and wired WebP/AVIF encode/decode into runtime service.
3. Added round-trip tests for WebP and AVIF.
4. Installed and integrated `vtracer` via `ExternalVTracerService` in `SplineVectorization`.
5. Added SVG conversion integration test and retained deterministic internal fallback path.
6. Updated CI workflow to install codec dependencies.
7. Updated dependency lock, notices, and dependency report.
8. Updated phase review docs and executed full strict quality gates.

### Decisions made
1. External codec integration uses native C bridges with fail-closed behavior when unavailable.
2. External tracer integration is attempted first on supported raster formats with deterministic internal fallback.

### Files changed
- `.github/workflows/ci.yml`
- `DEPENDENCIES.md`
- `THIRD_PARTY_NOTICES.md`
- `dependency-report.json`
- `Packages/SplineConversionEngine/Package.swift`
- `Packages/SplineConversionEngine/Sources/CWebPBridge/*`
- `Packages/SplineConversionEngine/Sources/CAVIFBridge/*`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/ExternalCodecBridge.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/ImageIOCodecService.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/ExternalCodecBridgeTests.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/ExternalVTracerService.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGConversionService.swift`
- `Packages/SplineVectorization/Tests/SplineVectorizationTests/SVGConversionServiceTests.swift`
- `docs/reviews/phase-1-review.md`
- `docs/reviews/phase-3-review.md`
- `docs/reviews/phase-4-review.md`
- `sessions.md`

### Tests / verification
- Command: `scripts/run-quality-gates.sh`
- Result: Pass
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. macOS linker emits deployment-target warnings for Homebrew dylibs built against newer SDK version.
2. iOS packaging of third-party native codecs needs dedicated build and distribution strategy before app target release.

### Open questions created or updated
- O-004 remains open for EPS parity strategy across platforms.

### Next recommended actions
1. Implement app-target integration and end-to-end conversion workflows using new codec and tracing services.
2. Add matrix integration tests for additional format pairs and animation policy paths.

## Session 2026-03-12 16:12 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Expand practical format matrix conversion paths.
2. Wire application and storage runtime modules for executable orchestration.

### Actions performed
1. Expanded conversion runtime to route PNG/JPEG/BMP/HEIC/GIF/TIFF/WEBP/AVIF/HDR/PDF/RAW into raster and emit raster/PDF/SVG outputs where implemented.
2. Added PDF raster decode and PDF encode support in `FileConversionService`.
3. Added RAW decode support via Core Image in `FileConversionService`.
4. Added storage module with app paths and conversion history persistence actors.
5. Added application module orchestration actor and bootstrap composition.
6. Added integration tests for file conversion, storage persistence, and orchestrator flow.
7. Updated phase review reports and reran strict quality gates.

### Decisions made
1. EPS and SVG-as-raster source remain explicit fail-closed paths until dedicated renderers are integrated.
2. Conversion orchestration records both success and failure outcomes to history.

### Files changed
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionServiceTests.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGConversionService.swift`
- `Packages/SplineStorage/Sources/SplineStorage/AppPaths.swift`
- `Packages/SplineStorage/Sources/SplineStorage/ConversionHistoryStore.swift`
- `Packages/SplineStorage/Tests/SplineStorageTests/SplineStorageTests.swift`
- `Packages/SplineApplication/Sources/SplineApplication/ApplicationBootstrap.swift`
- `Packages/SplineApplication/Sources/SplineApplication/ConversionOrchestrator.swift`
- `Packages/SplineApplication/Tests/SplineApplicationTests/SplineApplicationTests.swift`
- `docs/reviews/phase-3-review.md`
- `docs/reviews/phase-5-review.md`
- `docs/reviews/phase-6-review.md`
- `sessions.md`

### Tests / verification
- Command: `scripts/run-quality-gates.sh`
- Result: Pass
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. EPS and SVG source rasterization are not yet implemented and currently return unsupported errors.
2. Homebrew dylib deployment-target warnings remain for local macOS toolchain linkage.

### Open questions created or updated
- O-004 remains open and now directly impacts EPS roadmap completion.

### Next recommended actions
1. Implement EPS source rendering path and SVG source rasterization path.
2. Expand matrix tests for PDF/RAW/WebP/AVIF combinations and animation policy execution.

## Session 2026-03-12 16:27 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Execute requested sequence: EPS path, SVG source rasterization, matrix test expansion, app target wiring.

### Actions performed
1. Added EPS decode path in conversion engine with typed decode-failure behavior.
2. Added SVG rasterization service and integrated SVG source conversion for raster targets.
3. Added matrix conversion tests (WebP/AVIF paths) and animation planning coverage test.
4. Added concrete iOS and macOS SwiftUI app targets and XcodeGen project spec.
5. Added step-by-step review documents for each requested item.
6. Ran strict lint/tests/zero-debt verification.

### Decisions made
1. SVG rasterizer currently supports canvas attributes and rectangle primitives for deterministic fallback.
2. App targets are source-complete and generation-ready via XcodeGen.

### Files changed
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionServiceTests.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGRasterizer.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGConversionService.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/MatrixConversionTests.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/SplineConversionEngineTests.swift`
- `Apps/Spline-iOS/Sources/SplineiOSApp.swift`
- `Apps/Spline-macOS/Sources/SplinemacOSApp.swift`
- `Apps/project.yml`
- `Apps/README.md`
- `docs/reviews/step-1-eps-path-review.md`
- `docs/reviews/step-2-svg-rasterization-review.md`
- `docs/reviews/step-3-matrix-and-animation-review.md`
- `docs/reviews/step-4-app-target-wiring-review.md`
- `sessions.md`

### Tests / verification
- Command: `scripts/run-quality-gates.sh`
- Result: Pass
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. SVG rasterization currently covers a focused subset of SVG primitives; richer SVG support remains to be implemented.
2. Local linkage warning persists for Homebrew dynamic libs built with newer SDK target.

### Open questions created or updated
- O-004 continues to affect EPS parity expectations across platforms.

### Next recommended actions
1. Extend SVG rasterizer support to additional primitives and path data.
2. Expand EPS rendering fallback strategy for broader compatibility.
3. Wire iPadOS app target in generated app project with keyboard and files workflows.

## Session 2026-03-12 16:55 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Execute requested items 1-3 sequentially: richer SVG raster support, EPS fallback, iPadOS/files wiring.

### Actions performed
1. Expanded SVG rasterizer to support `rect`, `circle`, `line`, and basic `path` commands (`M`, `L`, `Z`).
2. Refactored SVG parsing into dedicated parser module for maintainability.
3. Added tiered EPS decoding fallback path (ImageIO, Core Image, macOS `sips` conversion fallback).
4. Added iPadOS app target wiring and Files integration conversion flow (`fileImporter` + conversion + `fileExporter`).
5. Added targeted review documents for each requested item.
6. Ran strict quality gates and zero-debt verification.

### Decisions made
1. SVG parser remains deterministic and intentionally scoped to core primitives while remaining extendable.
2. EPS fallback prioritizes native decode paths before process-based conversion fallback.
3. iPadOS target uses explicit app target with device-family-specific wiring.

### Files changed
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGRasterizer.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGDocumentParser.swift`
- `Packages/SplineVectorization/Tests/SplineVectorizationTests/SVGRasterizerTests.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService.swift`
- `Apps/Spline-iOS/Sources/FileConversionFlowView.swift`
- `Apps/Spline-iOS/Sources/SplineiOSApp.swift`
- `Apps/Spline-iPadOS/Sources/SplineiPadOSApp.swift`
- `Apps/project.yml`
- `Apps/README.md`
- `docs/reviews/next-1-svg-primitives-review.md`
- `docs/reviews/next-2-eps-fallback-review.md`
- `docs/reviews/next-3-ipados-files-flow-review.md`
- `sessions.md`

### Tests / verification
- Command: `scripts/run-quality-gates.sh`
- Result: Pass
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. SVG path support currently covers core path commands and should be expanded for full SVG path grammar.
2. EPS fallback via `sips` is macOS-specific and needs platform-specific strategy for non-macOS targets.

### Open questions created or updated
- O-004 remains open for final EPS parity contract.

### Next recommended actions
1. Expand SVG path grammar support (curves, arcs, relative multi-segment paths).
2. Add iPadOS keyboard interaction tests and Files workflow integration tests at app layer.

## Session 2026-03-12 19:32 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Continue SVG grammar depth implementation for path parsing and rendering.

### Actions performed
1. Added dedicated `SVGPathDataParser` module for tokenized SVG path parsing.
2. Expanded path command support to include `H/V/C/S/Q/T/A` and relative variants.
3. Updated rasterizer rendering to draw cubic and quadratic curves.
4. Kept deterministic arc fallback behavior by mapping arc segments to endpoint lines.
5. Ran strict lint/tests/zero-debt verification.

### Decisions made
1. Arc command support currently prioritizes stable endpoint interpretation over full elliptical arc tessellation.

### Files changed
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGDocumentParser.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGPathDataParser.swift`
- `Packages/SplineVectorization/Sources/SplineVectorization/SVGRasterizer.swift`
- `docs/reviews/next-1-svg-primitives-review.md`
- `sessions.md`

### Tests / verification
- Command: `scripts/run-quality-gates.sh`
- Result: Pass
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. Full geometric elliptical arc reconstruction is still a targeted future enhancement.

### Next recommended actions
1. Implement full elliptical arc reconstruction for `A/a` commands.
2. Add additional SVG path conformance fixtures for mixed command streams.

## Session 2026-03-12 22:35 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Close post-merge delivery gaps for animation policy runtime behavior, color management, and metadata verification.
2. Restore protected workflow and enumerate remaining release-plan decisions.

### Actions performed
1. Implemented runtime animation policy execution in conversion runtime for `preserveWhenSupported`, `firstFrameOnly`, and `splitToFrames`.
2. Added animated decode/encode support paths and split-frame manifest output.
3. Hardened raster output color normalization with explicit output color-space handling and CMYK fallback.
4. Added metadata policy extension (`preserve`) and verification tests for strip-by-default plus preserve passthrough.
5. Split work into focused PR slices and merged stacked PRs #2, #3, #4.
6. Re-enabled `main` branch protection with required checks and required review approval.

### Decisions made
1. Runtime animation policy behavior is now executed in production conversion flow, not only in planning metadata.
2. `MetadataPolicy` now supports `preserve` in addition to `strip`.

### Files changed
- `Packages/SplineDomain/Sources/SplineDomain/ConversionOptions.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService+Animation.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService+Color.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/FileConversionService+DecodeEncode.swift`
- `Packages/SplineConversionEngine/Sources/SplineConversionEngine/ImageIOCodecService.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionServiceTests.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionServiceTests+Helpers.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionAnimationPolicyTests.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionColorManagementTests.swift`
- `Packages/SplineConversionEngine/Tests/SplineConversionEngineTests/FileConversionMetadataPolicyTests.swift`

### Tests / verification
- Command: `scripts/run-quality-gates.sh`
- Result: Pass
- Command: `node ~/.pi/agent/zero-debt/scripts/zero-debt-verify.mjs`
- Result: Pass

### Risks found
1. Open product decisions O-001 through O-004 remain unresolved and are potential release blockers.
2. EPS parity user-facing contract still requires explicit product sign-off (O-004).

### Open questions created or updated
- O-001 remains Open.
- O-002 remains Open.
- O-003 remains Open.
- O-004 remains Open.

### Next recommended actions
1. Resolve O-001 to O-004 and update ADR-0001 or a follow-up ADR with final decisions.
2. Finalize EPS parity matrix and user-facing downgrade/warning policy tied to O-004.
3. Complete Phase 7 closeout checklist items (RC sign-off, determinism exceptions, performance thresholds).
4. Complete Phase 8 closeout checklist items (artifact archiving and launch outcome logging).

## Session 2026-03-12 22:55 GMT+10

### Participants
- Human: Product Owner
- Agent: Coding Assistant

### Objectives
1. Resolve product decision backlog O-001 through O-004.
2. Finalize EPS parity contract and complete Phase 7/Phase 8 closeout records.

### Actions performed
1. Added ADR-0002 to resolve accessibility baseline, min OS targets, OCR scope, and EPS parity behavior contract.
2. Updated decision status in open decisions register (O-001..O-004 marked resolved).
3. Added RC quality sign-off, determinism report, and performance threshold validation records.
4. Added submission artifact and license/compliance archive index records.
5. Updated Phase 7 and Phase 8 package checklists to completed state with evidence links.

### Decisions made
1. O-001 resolved by ADR-0002.
2. O-002 resolved by ADR-0002.
3. O-003 resolved by ADR-0002.
4. O-004 resolved by ADR-0002 with explicit platform matrix and user-facing policy.

### Files changed
- `docs/adr/ADR-0001-spline-product-and-technical-foundation.md`
- `docs/adr/ADR-0002-v1-product-decisions-and-eps-parity-contract.md`
- `execution-packages/phase-7-quality-hardening/package.md`
- `execution-packages/phase-8-app-store-launch/package.md`
- `docs/release/rc-quality-signoff-2026-03-12.md`
- `docs/release/determinism-report-2026-03-12.md`
- `docs/release/performance-thresholds-2026-03-12.md`
- `docs/release/submission-artifacts-archive-2026-03-12.md`
- `docs/release/license-compliance-evidence-2026-03-12.md`
- `sessions.md`

### Tests / verification
- Documentation update only; no runtime code changes.

### Risks found
1. App Store approval is an external process and remains pending even with closeout evidence prepared.

### Open questions created or updated
- None.

### Next recommended actions
1. Keep branch-protected PR workflow active for all subsequent changes.
2. Execute App Store submission operations per `docs/release/app-store-submission-runbook.md`.
