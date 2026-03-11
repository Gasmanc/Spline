# Spline Phased Delivery Plan (Agent-Agnostic)

This plan is implementation-agent agnostic. It is written so any capable engineering contributor (human or AI) can execute the same sequence with consistent outcomes.

## Plan objectives

1. Deliver a production-grade, App Store-ready, free application.
2. Implement full matrix image conversion and high-fidelity SVG conversion.
3. Preserve architectural integrity, quality, and legal compliance.
4. Avoid hidden technical debt by making decisions explicit and verifiable.

---

## Phase 0: Foundation alignment and readiness

## Purpose
Convert discovery answers into enforceable engineering artifacts and acceptance gates.

## Inputs
- `PRD.md`
- `architecture.md`
- `docs/adr/ADR-0001-spline-product-and-technical-foundation.md`

## Work items
1. Confirm unresolved decision owners and deadlines (accessibility, deployment versions, OCR scope, EPS parity).
2. Create engineering repository skeleton with module structure from architecture document.
3. Define and commit coding standards and CI quality gates.
4. Define dependency policy enforcement workflow (license check + SBOM generation).
5. Define test asset ingestion strategy and fixture governance.

## Deliverables
1. Repository structure with modules and package boundaries.
2. CI pipeline scaffolding in GitHub Actions.
3. Quality gate configuration (lint, test, static checks, license checks).
4. Issue tracker templates for feature, bug, quality regression.

## Exit criteria
1. CI runs successfully on empty/skeleton modules.
2. All open product decisions have owners and due dates tracked.

---

## Phase 1: Dependency lock, legal verification, and codec strategy finalization

## Purpose
Select and lock implementation dependencies with permissive licensing and App Store compatibility.

## Work items
1. Evaluate and finalize third-party packages for:
   - WebP
   - AVIF
   - SVG parsing/writing
   - Raster vectorization engine
2. Validate each dependency license and transitive license.
3. Record attribution requirements.
4. Verify binary integration approach (SPM/XCFramework/C bridge/Rust bridge) for all selected packages.
5. Run compatibility proofs for target platforms.

## Deliverables
1. `DEPENDENCIES.md` with exact versions, license IDs, and usage rationale.
2. Automated CI license verification step.
3. Early codec smoke-test executable proving decode/encode for selected formats.

## Exit criteria
1. No non-permissive runtime dependencies remain.
2. Dependency legal report approved.
3. Smoke tests pass on iOS, iPadOS, macOS build targets.

---

## Phase 2: Core domain and conversion graph engine

## Purpose
Implement deterministic conversion planning and capability-aware routing.

## Work items
1. Implement domain entities (`ImageFormat`, `ConversionIntent`, `ConversionPlan`, etc.).
2. Implement format capability registry.
3. Implement conversion graph service and weighted path planner.
4. Implement downgrade warning rule set (alpha loss, animation loss, color-space mismatch).
5. Implement canonical intermediate representations.
6. Implement planner unit and property-based tests.

## Deliverables
1. `SplineDomain` module production-complete.
2. `SplineConversionEngine` planner core production-complete.
3. Unit tests and integration tests for graph correctness.

## Exit criteria
1. Full matrix path resolution succeeds for all declared format pairs.
2. Unsupported semantic transitions always emit explicit warning metadata.

---

## Phase 3: Decoding/encoding pipeline implementation

## Purpose
Implement robust, tested per-format decode and encode paths.

## Work items
1. Implement decoder registry and pluggable decoder interfaces.
2. Implement encoder registry and pluggable encoder interfaces.
3. Integrate Apple frameworks and selected OSS codecs.
4. Implement animation handling policies.
5. Implement metadata strip policy default.
6. Implement color profile carry-through and transform hooks.
7. Build format-by-format integration tests.

## Deliverables
1. Decode/encode runtime for required format set.
2. Conversion matrix smoke suite.
3. Error model with user-actionable diagnostics.

## Exit criteria
1. End-to-end conversion works for all required format pairs at baseline quality.
2. Metadata stripping and alpha handling are validated by tests.

---

## Phase 4: SVG pipeline (vector preservation and tracing)

## Purpose
Deliver the primary product capability with fidelity-first behavior.

## Work items
1. Implement vector-preserving pipeline for vector-capable source inputs.
2. Implement forced rasterization mode.
3. Implement raster-to-SVG tracing pipeline with user-selectable modes:
   - color (default)
   - black-and-white
4. Implement advanced tracing controls (macOS and iPadOS feature gating).
5. Implement OCR-assisted text replacement option with quality guardrails.
6. Implement RAW preprocessing chain: demosaic + color correction + trace.
7. Build SVG-specific fidelity regression suite.

## Deliverables
1. Production-ready SVG pipeline across supported inputs.
2. UI control surface for all required SVG options.
3. Fidelity benchmark results and acceptance report.

## Exit criteria
1. SVG conversion passes golden/perceptual quality thresholds.
2. Vector preservation works where technically possible and falls back safely when not.

---

## Phase 5: Job system, background execution, and history

## Purpose
Enable robust real-world throughput and reliable interrupted-work recovery.

## Work items
1. Implement durable job queue state machine.
2. Implement pause/resume/retry/cancel semantics.
3. Implement background scheduling behavior per platform constraints.
4. Implement checkpoint persistence and restart recovery.
5. Implement history browsing and rerun workflow.
6. Add job-level diagnostics and local export.

## Deliverables
1. `SplineJobs` module production-complete.
2. Queue UI and history UI production-complete.
3. Recovery test suite.

## Exit criteria
1. Jobs survive interruption and resume correctly.
2. Batch conversion workflow is stable on all platforms.

---

## Phase 6: UX completion and platform integration

## Purpose
Complete user workflows and platform-native interactions.

## Work items
1. Implement drag-and-drop ingestion and destination interactions.
2. Implement Files integration for iOS/iPadOS.
3. Implement Finder-centric behavior for macOS.
4. Implement keyboard shortcuts and full keyboard operation for macOS/iPadOS.
5. Implement error dialogs and capability warnings.
6. Refine pro-feature visibility rules by platform.

## Deliverables
1. End-to-end UX for single and batch workflows.
2. Keyboard command map documentation.
3. Platform interaction acceptance report.

## Exit criteria
1. All required workflows from PRD pass manual and automated acceptance tests.
2. Keyboard workflows complete for all critical actions.

---

## Phase 7: Quality hardening and release candidate stabilization

## Purpose
Raise reliability, performance, and visual consistency to release bar.

## Work items
1. Expand golden/perceptual regressions across full format matrix.
2. Run performance profiling for large assets and batches.
3. Optimize hot paths (GPU first where safe, CPU fallback retained).
4. Run determinism test suite and record exceptions.
5. Run long-duration soak and memory pressure tests.
6. Execute crash triage and zero known blocker policy.

## Deliverables
1. Release-candidate quality report.
2. Performance benchmark report.
3. Determinism report and documented known boundaries.

## Exit criteria
1. No release-blocking defects open.
2. Performance and stability thresholds met.

---

## Phase 8: App Store readiness and launch

## Purpose
Complete legal, operational, and submission readiness.

## Work items
1. Finalize App privacy questionnaire with zero data collection posture.
2. Finalize third-party attributions and notices.
3. Validate signing, entitlements, and archive reproducibility.
4. Prepare screenshots, metadata, and localization assets as needed.
5. Conduct TestFlight stabilization cycle.
6. Submit to App Store and monitor review feedback.

## Deliverables
1. App Store submission package.
2. Release notes and known limitations document.
3. Post-launch triage plan.

## Exit criteria
1. App approved and published.
2. Post-launch support workflow active.

---

## Cross-phase governance tracks

## A. Security and privacy track
- Verify no telemetry or outbound analytics codepaths.
- Ensure local-only processing claims remain true.

## B. Legal and licensing track
- Enforce dependency license checks in every CI run.
- Keep SBOM current per release candidate.

## C. Quality and testing track
- Maintain matrix dashboard by format pair and platform.
- Prevent regressions with blocking CI thresholds.

## D. Documentation track
- Keep ADR, PRD, architecture, and sessions ledger synchronized.
- Update user-facing help for feature and capability changes.

---

## Detailed testing and QA matrix (execution reference)

| Category | Test Type | Scope | Gate |
|----------|-----------|-------|------|
| Unit | Planner correctness | All format nodes/edges | Required |
| Unit | Capability rules | Alpha/animation/color-space semantics | Required |
| Integration | Decode/encode | Every format | Required |
| Integration | Matrix conversion | Every format pair | Required |
| Integration | SVG conversion | Vector-preserving + trace paths | Required |
| Regression | Golden/perceptual | Representative corpus | Required |
| Reliability | Resume/restart | Job durability scenarios | Required |
| Performance | Throughput/latency | Large files and batches | Required |
| UX | Keyboard and workflows | macOS + iPadOS keyboard parity | Required |
| Privacy | Network emission check | All runtime paths | Required |

---

## App Store readiness checklist (execution reference)

1. App Privacy declaration confirms no tracking and no data collection.
2. No analytics SDK binaries or symbols present.
3. Dependency attribution and licenses included.
4. Export compliance declarations validated.
5. Entitlements minimal and justified.
6. Accessibility baseline completed and verified.
7. Crash rate and memory stability meet release threshold.
8. Screenshots and metadata complete per device family.
9. TestFlight results accepted.
10. Rollback and hotfix plan prepared.

---

## Operating model for agent-agnostic execution

1. Every phase has explicit entry and exit criteria.
2. Every agent must update `sessions.md` after each work session.
3. No phase is marked complete without objective evidence in repository artifacts.
4. If open decisions block progress, create/update ADR and open decision record before implementation proceeds.
