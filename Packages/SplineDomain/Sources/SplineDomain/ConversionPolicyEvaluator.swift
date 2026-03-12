import Foundation

public enum ConversionPolicyEvaluator {
    public static func warnings(for intent: ConversionIntent) -> [ConversionWarning] {
        let sourceCapabilities = FormatCapabilityRegistry.capabilities(for: intent.sourceFormat)
        let targetCapabilities = FormatCapabilityRegistry.capabilities(for: intent.targetFormat)
        var items: [ConversionWarning] = []

        if intent.containsAlphaChannel && !targetCapabilities.supportsAlpha {
            items.append(.alphaWillBeDiscarded)
        }

        if intent.containsAnimation && !targetCapabilities.supportsAnimation {
            items.append(.animationWillBeReduced)
        }

        if intent.options.outputColorSpace == .cmyk && !targetCapabilities.supportsCMYKEncoding {
            items.append(.cmykNotSupportedByTarget)
        }

        if intent.targetFormat == .svg
            && intent.options.svgMode == .preserveVectorWhenPossible
            && !sourceCapabilities.supportsVectorPrimitives {
            items.append(.vectorPreservationUnavailable)
        }

        return items
    }
}
