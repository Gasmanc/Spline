import Foundation
import SplineDomain

public struct FileConversionService: Sendable {
    private let planner: ConversionGraphPlanner
    private let codecs: ImageIOCodecService

    public init(
        planner: ConversionGraphPlanner = ConversionGraphPlanner(),
        codecs: ImageIOCodecService = ImageIOCodecService()
    ) {
        self.planner = planner
        self.codecs = codecs
    }

    public func convert(
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent
    ) throws -> ConversionPlan {
        let plan = planner.plan(for: intent)

        if intent.targetFormat.isVector {
            throw ConversionEngineError.unsupportedFormat
        }

        if intent.sourceFormat.isVector {
            throw ConversionEngineError.unsupportedFormat
        }

        let image = try codecs.decodeRasterImage(at: inputURL, as: intent.sourceFormat)
        try codecs.encodeRasterImage(image, to: outputURL, as: intent.targetFormat)

        return plan
    }
}
