# Phase 4 Execution Package: SVG Primary Pipeline

## Objective
Deliver the primary value proposition: high-fidelity conversion to SVG with vector-preserving and trace-based modes.

## Detailed work breakdown
1. Implement vector-preserving path for SVG/PDF/EPS sources where technically feasible.
2. Implement forced rasterization path for all sources.
3. Integrate raster-to-vector tracing engine with color default mode and black-and-white mode.
4. Implement advanced tracing controls on macOS and iPadOS.
5. Integrate optional OCR text layer replacement where it improves visual fidelity.
6. Add RAW-specific preprocess chain (demosaic + color correction + tracing).
7. Add SVG regression tests and visual acceptance fixtures.

## Deliverables
- `SplineVectorization` production pipeline
- User-facing SVG conversion controls
- SVG quality benchmark report

## Acceptance criteria
- SVG output fidelity passes thresholds.
- Mode selection and fallback behavior are explicit and reliable.
- RAW-to-SVG pipeline meets quality targets.

## Handoff checklist to Phase 5
- [ ] SVG regression suite stable
- [ ] Advanced controls gated by platform as specified
- [ ] OCR option behavior documented
