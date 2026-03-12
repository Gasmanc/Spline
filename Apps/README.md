# App Targets

This directory contains concrete app target source code and an XcodeGen project spec.

## Targets
- `Spline-iOS` (iOS/iPadOS SwiftUI app)
- `Spline-macOS` (macOS SwiftUI app with keyboard command wiring)

## Generate Xcode project
1. Install XcodeGen (`brew install xcodegen`)
2. Run from `Apps/`:
   - `xcodegen generate`

## Notes
- App sources are wired to package modules: `SplineApplication`, `SplineUI`, `SplineStorage`.
- Production signing, capabilities, and App Store metadata configuration are completed at release staging.
