# App Targets

This directory contains concrete app target source code and an XcodeGen project spec.

## Targets
- `Spline-iOS` (iPhone-targeted SwiftUI app)
- `Spline-iPadOS` (iPad-targeted SwiftUI app with keyboard commands)
- `Spline-macOS` (macOS SwiftUI app with keyboard command wiring)

## Files integration flow
- iOS and iPadOS use `FileConversionFlowView`.
- This flow includes:
  1. Files picker (`fileImporter`) for input selection.
  2. In-app conversion execution using `FileConversionService`.
  3. Files export (`fileExporter`) for saving converted output.

## Generate Xcode project
1. Install XcodeGen (`brew install xcodegen`)
2. Run from `Apps/`:
   - `xcodegen generate`

## Notes
- App sources are wired to package modules: `SplineApplication`, `SplineUI`, `SplineStorage`, `SplineConversionEngine`, `SplineDomain`.
- Production signing, capabilities, and App Store metadata configuration are completed at release staging.
