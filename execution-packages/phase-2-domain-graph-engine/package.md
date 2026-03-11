# Phase 2 Execution Package: Core Domain and Conversion Graph Engine

## Objective
Implement deterministic, quality-prioritized conversion planning using explicit format capability rules.

## Detailed work breakdown
1. Implement domain entities and invariants.
2. Implement format capability registry and semantic compatibility rules.
3. Implement conversion graph representation and weighted pathfinding.
4. Implement downgrade warning emission model.
5. Add comprehensive unit and property tests.

## Deliverables
- `SplineDomain` core models
- Planner and scoring services in `SplineConversionEngine`
- Test suites for planner/capability correctness

## Acceptance criteria
- Full source-target matrix path planning succeeds.
- Incompatible semantic transitions return explicit warnings.
- Deterministic ordering policy is documented and tested.

## Handoff checklist to Phase 3
- [ ] Planner contracts frozen
- [ ] Capability matrix published
- [ ] Test baseline green
