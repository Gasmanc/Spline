import Foundation
import SplineDomain

public struct ConversionGraphPlanner: Sendable {
    public init() {}

    public func plan(for intent: ConversionIntent) -> ConversionPlan {
        let warnings = ConversionPolicyEvaluator.warnings(for: intent)
        var steps: [ConversionStep] = []

        if intent.sourceFormat == .raw {
            steps.append(.developRaw)
        }

        if intent.containsAnimation {
            steps.append(.selectAnimationFrames)
        }

        if intent.targetFormat == .svg {
            steps.append(contentsOf: stepsToSVG(intent: intent))
        } else {
            steps.append(contentsOf: stepsToRasterOrVectorTarget(intent: intent))
        }

        if intent.options.metadataPolicy == .strip {
            steps.append(.stripMetadata)
        }

        steps = normalizeColorStepIfRequired(intent: intent, existing: steps)

        return ConversionPlan(steps: steps, warnings: warnings)
    }

    private func stepsToSVG(intent: ConversionIntent) -> [ConversionStep] {
        if intent.options.svgMode == .preserveVectorWhenPossible && intent.sourceFormat.isVector {
            return [.decodeVector, .preserveVectorToSVG, .encodeVector]
        }

        if intent.sourceFormat.isVector {
            return [.decodeVector, .rasterizeVector, .traceRasterToSVG, .encodeVector]
        }

        return [.decodeRaster, .traceRasterToSVG, .encodeVector]
    }

    private func stepsToRasterOrVectorTarget(intent: ConversionIntent) -> [ConversionStep] {
        if intent.sourceFormat.isVector {
            return [.decodeVector, .rasterizeVector, .encodeRaster]
        }

        return [.decodeRaster, .encodeRaster]
    }

    private func normalizeColorStepIfRequired(intent: ConversionIntent, existing: [ConversionStep]) -> [ConversionStep] {
        guard intent.options.preserveICCProfile || intent.options.outputColorSpace != .sRGB else {
            return existing
        }

        var steps = existing
        if let encodeIndex = steps.lastIndex(where: { $0 == .encodeRaster || $0 == .encodeVector }) {
            steps.insert(.normalizeColor, at: encodeIndex)
        }
        return steps
    }
}
