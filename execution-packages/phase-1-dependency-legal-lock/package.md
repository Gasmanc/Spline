# Phase 1 Execution Package: Dependency and Legal Lock

## Objective
Select, validate, and lock all external dependencies with permissive licenses and App Store compatibility.

## Detailed work breakdown
1. Build candidate list per capability gap (WebP, AVIF, vector tracing, SVG parser/writer).
2. Verify direct and transitive licenses.
3. Confirm binary integration method and Apple platform compatibility.
4. Produce dependency bill of materials and third-party notice draft.
5. Run smoke tests proving integration works on all targets.

## Deliverables
- `DEPENDENCIES.md`
- `THIRD_PARTY_NOTICES.md`
- Updated lock files and integration adapters
- CI license gate report

## Acceptance criteria
- No non-permissive dependency in runtime graph.
- Every dependency has recorded rationale and version pin.
- Smoke conversion test passes on all platforms.

## Handoff checklist to Phase 2
- [ ] Dependency lock approved
- [ ] License gate stable in CI
- [ ] Integration adapter contracts finalized
