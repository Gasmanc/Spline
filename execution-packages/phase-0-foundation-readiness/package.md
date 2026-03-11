# Phase 0 Execution Package: Foundation Alignment and Readiness

## Objective
Establish enforceable engineering foundations so all subsequent phases can execute without ambiguity, legal drift, or quality inconsistency.

## Inputs
- `PRD.md`
- `architecture.md`
- `docs/adr/ADR-0001-spline-product-and-technical-foundation.md`
- `phased-plan.md`

## Detailed work breakdown

### Workstream A: Decision governance
1. Resolve and assign all open decisions with owners and due dates.
2. Record decision dependencies and blockers.
3. Add explicit escalation path for overdue product decisions.

### Workstream B: Repository skeleton and module boundaries
1. Create app and package directory topology.
2. Create shared module naming conventions.
3. Create initial package manifests and target declarations.
4. Add boundary ownership documentation.

### Workstream C: Engineering standards and quality gates
1. Define Swift style, lint, and formatting standards.
2. Define branch protections and pull request quality checklist.
3. Define required CI checks and blocking conditions.

### Workstream D: License and compliance workflow
1. Define permissive-license allowlist.
2. Define dependency inventory source of truth.
3. Create automated CI check for dependency policy conformance.
4. Define SBOM generation policy and artifact retention.

### Workstream E: Test fixture governance
1. Define fixture ingestion rules.
2. Define golden image corpus structure.
3. Define acceptance thresholds and drift process.

## Deliverables
1. Repository skeleton and module directories.
2. CI baseline workflow file.
3. Standards documentation and lint configuration.
4. Dependency policy files and baseline validation scripts.
5. Testing fixture governance documentation.
6. Updated `sessions.md` entry documenting execution evidence.

## Acceptance criteria
1. CI runs green on default branch with baseline checks enabled.
2. Repository structure matches architecture module boundaries.
3. Dependency policy enforcement job executes in CI.
4. Open decisions are tracked with owner and due date.

## Evidence required
- CI run URL
- File list of created standards/configuration artifacts
- Snapshot of open decision register with owner and date

## Risks and controls
- **Risk:** CI configured but non-blocking.  
  **Control:** Mark critical checks as required status checks.
- **Risk:** Dependency policy only documented, not executable.  
  **Control:** Enforce via script and CI step.

## Handoff checklist to Phase 1
- [ ] Dependency candidate list prepared
- [ ] License allowlist approved
- [ ] Build/test/lint baseline stable
