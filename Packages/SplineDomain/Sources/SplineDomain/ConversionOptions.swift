import Foundation

public enum OutputColorSpace: String, Codable, Sendable {
    case sRGB
    case displayP3
    case cmyk
}

public enum AnimationPolicy: String, Codable, Sendable {
    case firstFrameOnly
    case preserveWhenSupported
    case splitToFrames
}

public enum SVGMode: String, Codable, Sendable {
    case preserveVectorWhenPossible
    case forceRasterTrace
}

public enum TraceMode: String, Codable, Sendable {
    case color
    case blackAndWhite
}

public struct TraceControls: Codable, Sendable, Equatable {
    public let threshold: Float
    public let despeckle: Float
    public let cornerSmoothing: Float
    public let pathSimplification: Float

    public init(
        threshold: Float = 0.5,
        despeckle: Float = 0,
        cornerSmoothing: Float = 0.2,
        pathSimplification: Float = 0.15
    ) {
        self.threshold = threshold
        self.despeckle = despeckle
        self.cornerSmoothing = cornerSmoothing
        self.pathSimplification = pathSimplification
    }
}

public enum MetadataPolicy: String, Codable, Sendable {
    case strip
    case preserve
}

public struct ConversionOptions: Codable, Sendable, Equatable {
    public let outputColorSpace: OutputColorSpace
    public let animationPolicy: AnimationPolicy
    public let svgMode: SVGMode
    public let traceMode: TraceMode
    public let traceControls: TraceControls
    public let metadataPolicy: MetadataPolicy
    public let preserveICCProfile: Bool
    public let requireDeterministicOutput: Bool

    public init(
        outputColorSpace: OutputColorSpace,
        animationPolicy: AnimationPolicy = .preserveWhenSupported,
        svgMode: SVGMode = .preserveVectorWhenPossible,
        traceMode: TraceMode = .color,
        traceControls: TraceControls = TraceControls(),
        metadataPolicy: MetadataPolicy = .strip,
        preserveICCProfile: Bool = true,
        requireDeterministicOutput: Bool = true
    ) {
        self.outputColorSpace = outputColorSpace
        self.animationPolicy = animationPolicy
        self.svgMode = svgMode
        self.traceMode = traceMode
        self.traceControls = traceControls
        self.metadataPolicy = metadataPolicy
        self.preserveICCProfile = preserveICCProfile
        self.requireDeterministicOutput = requireDeterministicOutput
    }
}
