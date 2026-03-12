# ADR-0002: V1 Product Decisions and EPS Parity Contract

- **Status:** Accepted
- **Date:** 2026-03-12
- **Decision Makers:** Product Owner, Engineering
- **Supersedes Open Decisions:** O-001, O-002, O-003, O-004 in `sessions.md`

## Context

ADR-0001 intentionally left four product decisions open so implementation could proceed while policy details were finalized:

1. O-001 Accessibility depth baseline
2. O-002 Exact minimum OS versions
3. O-003 OCR language/script scope
4. O-004 EPS parity behavior across iOS/iPadOS/macOS

These decisions now need to be fixed to remove release ambiguity.

## Decision

### D1. Accessibility baseline (resolves O-001)
For v1, Spline must meet a WCAG-inspired native accessibility baseline across iOS, iPadOS, and macOS:

1. Full VoiceOver labeling for all interactive controls in conversion workflow, job management, and history screens.
2. Dynamic Type support for all text in iOS/iPadOS SwiftUI screens.
3. Minimum contrast target equivalent to WCAG AA for text/iconography in shipped themes.
4. Keyboard-only operation for macOS and iPadOS conversion flows.
5. Respect system accessibility settings for Reduce Motion and Increased Contrast where applicable.

### D2. Minimum deployment targets (resolves O-002)
The explicit minimum deployment targets for v1 are:

- iOS 16.0+
- iPadOS 16.0+
- macOS 13.0+

These targets align to the “last 4 years” product rule and existing package constraints.

### D3. OCR scope for v1 (resolves O-003)
OCR is optional and used only when it improves SVG fidelity. For v1:

1. OCR language support is limited to Latin-script recognition in system-provided Vision OCR capabilities.
2. Non-Latin script OCR is out-of-scope for v1 and treated as a future enhancement.
3. If OCR confidence is below threshold, pipeline falls back to non-text vectorization.

### D4. EPS parity contract (resolves O-004)
EPS behavior contract by platform:

- **macOS:**
  1. Try ImageIO decode.
  2. Fallback to CoreImage decode.
  3. Fallback to `sips` rasterization bridge.
  4. If all fail, surface typed decode failure with actionable user message.

- **iOS/iPadOS:**
  1. Try ImageIO decode.
  2. Fallback to CoreImage decode.
  3. No `sips` fallback available.
  4. If decode fails, return typed unsupported/decode failure and show user-facing downgrade guidance: “EPS conversion reliability is platform-limited on iOS/iPadOS; retry on macOS for best compatibility.”

User-facing policy:
- EPS conversion attempts are always explicit.
- Failures must never be silent.
- Warnings are shown before execution when planner detects EPS source on iOS/iPadOS.

## Consequences

### Positive
- Removes ambiguity for release sign-off.
- Aligns implementation and UX messaging for EPS limitations.
- Establishes concrete accessibility and platform support targets.

### Trade-offs
- OCR language coverage is intentionally conservative for v1.
- EPS parity remains best-effort on iOS/iPadOS due platform constraints.

## Validation criteria

This ADR is considered implemented when:

1. `sessions.md` O-001 through O-004 are marked resolved.
2. Deployment targets in package/app configuration match D2.
3. EPS behavior docs and user messaging reflect D4.
4. Accessibility baseline checks are present in RC sign-off evidence.
