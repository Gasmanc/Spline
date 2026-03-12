# Spline Dependency Lock

## Runtime dependencies currently locked

### First-party Apple frameworks
- SwiftUI
- Foundation
- CoreGraphics
- ImageIO
- CoreImage
- UniformTypeIdentifiers
- PDFKit
- Vision

### Third-party dependencies

1. **webp**
   - Version: 1.6.0
   - License: BSD-3-Clause
   - Integration: C bridge target `CWebPBridge`
   - Purpose: deterministic WebP decode and encode support

2. **libavif**
   - Version: 1.4.0
   - License: BSD-2-Clause
   - Integration: C bridge target `CAVIFBridge`
   - Purpose: deterministic AVIF decode and encode support

3. **vtracer**
   - Version: 0.6.5
   - License: MIT OR Apache-2.0 (tracked as MIT for allowlist compatibility)
   - Integration: process-based invocation through `ExternalVTracerService`
   - Purpose: permissive external high-quality raster-to-vector tracing path

## License policy conformance
All locked third-party dependencies are in the allowlist from `config/dependency-policy.json`.

## Build prerequisites
For local macOS builds and CI, install:
- `brew install webp libavif`
- `cargo install vtracer`

## Notes
- On platforms where these external dependencies are unavailable, conversion paths fail closed to typed errors or use the internal tracer path where possible.
