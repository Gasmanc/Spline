# Spline Engineering Standards

## Swift coding standards
1. Swift 6 language mode preferred where tooling allows.
2. Disallow force unwrap in production paths unless formally justified and tracked.
3. Disallow unsafe forced throwing invocation patterns and placeholder crash traps.
4. Prefer explicit error propagation and typed error domains.
5. Use value semantics for domain types unless reference semantics are required.

## Module boundaries
1. `SplineDomain` contains no UI or platform framework imports.
2. `SplineApplication` orchestrates use cases only.
3. Engine modules (`SplineConversionEngine`, `SplineVectorization`, `SplineColor`) do not depend on UI modules.
4. `SplineUI` can depend on `SplineApplication` and domain-facing view models only.

## Pull request quality gates
1. Unit tests added/updated for changed logic.
2. Integration tests updated for conversion behavior changes.
3. ADR update required for architecture-significant changes.
4. License review required for new dependencies.
5. `sessions.md` updated for each meaningful work session.

## Commit discipline
1. Small, reviewable commits.
2. No unrelated refactors mixed with feature work.
3. Commit message must include phase and scope reference.
