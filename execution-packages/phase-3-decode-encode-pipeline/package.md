# Phase 3 Execution Package: Decode/Encode Pipeline Implementation

## Objective
Implement robust decoding and encoding across all required formats with policy-compliant behavior.

## Detailed work breakdown
1. Build decoder and encoder registries.
2. Integrate Apple and third-party codec implementations.
3. Implement color policy, alpha handling, metadata stripping, and animation policy.
4. Add integration tests per format and matrix smoke tests.
5. Build structured error taxonomy with user-actionable diagnostics.

## Deliverables
- Decode/encode engine modules
- Conversion matrix smoke suite
- Error and warning taxonomy documentation

## Acceptance criteria
- Baseline conversion works for all required pairs.
- Policy behaviors validated by automated tests.
- Error paths are recoverable and user-explainable.

## Handoff checklist to Phase 4
- [ ] Stable raster/vector intermediate representations
- [ ] Animation policies implemented
- [ ] Matrix smoke tests passing
