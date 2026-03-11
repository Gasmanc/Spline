import Foundation

public enum ConversionStep: String, Codable, Sendable {
    case decodeRaster
    case decodeVector
    case developRaw
    case normalizeColor
    case preserveVectorToSVG
    case rasterizeVector
    case traceRasterToSVG
    case selectAnimationFrames
    case stripMetadata
    case encodeRaster
    case encodeVector
}

public enum ConversionWarning: String, Codable, Sendable, CaseIterable {
    case alphaWillBeDiscarded
    case animationWillBeReduced
    case cmykNotSupportedByTarget
    case vectorPreservationUnavailable
}

public struct ConversionPlan: Codable, Sendable, Equatable {
    public let steps: [ConversionStep]
    public let warnings: [ConversionWarning]

    public init(steps: [ConversionStep], warnings: [ConversionWarning]) {
        self.steps = steps
        self.warnings = warnings
    }
}
