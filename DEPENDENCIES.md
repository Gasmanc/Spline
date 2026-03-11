# Spline Dependency Lock

## Phase 1 status
This lock records dependencies approved for immediate integration.

## Runtime dependencies currently locked

1. Apple platform frameworks (first-party)
   - SwiftUI
   - Foundation
   - CoreGraphics
   - ImageIO
   - CoreImage
   - UniformTypeIdentifiers
   - PDFKit
   - Vision

License posture: first-party platform SDK components.

## External dependencies currently locked
None yet.

Rationale:
- Full legal and transitive validation is required before external codec/vectorization libraries are added.
- Runtime currently uses first-party frameworks only.

## Candidate queue requiring legal lock before integration

1. libwebp (BSD-3-Clause)
2. libavif (BSD-2-Clause)
3. Color-capable raster tracing library with permissive license
4. SVG parser and writer library with permissive license

## Policy
- Only licenses in `config/dependency-policy.json` are allowed.
- Any dependency with unknown license metadata is blocked.
- Dependency introduction requires update to `dependency-report.json` and `THIRD_PARTY_NOTICES.md`.
