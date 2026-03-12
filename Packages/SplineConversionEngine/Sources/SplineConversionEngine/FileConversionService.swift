import Foundation
import SplineDomain
import SplineVectorization

public struct FileConversionService: Sendable {
    let planner: ConversionGraphPlanner
    let codecs: ImageIOCodecService
    let svgService: SVGConversionService

    public init(
        planner: ConversionGraphPlanner = ConversionGraphPlanner(),
        codecs: ImageIOCodecService = ImageIOCodecService(),
        svgService: SVGConversionService = SVGConversionService()
    ) {
        self.planner = planner
        self.codecs = codecs
        self.svgService = svgService
    }

    public func convert(
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent
    ) throws -> ConversionPlan {
        let plan = planner.plan(for: intent)

        if shouldPassthroughToPreserveMetadata(intent: intent) {
            try copyInputToOutput(inputURL: inputURL, outputURL: outputURL)
            return plan
        }

        if intent.targetFormat == .svg {
            return try convertToSVG(inputURL: inputURL, outputURL: outputURL, intent: intent, plan: plan)
        }

        if intent.containsAnimation,
           !intent.sourceFormat.isVector,
           let animated = try codecs.decodeAnimatedRasterIfPresent(at: inputURL, as: intent.sourceFormat) {
            try convertAnimated(animated, inputURL: inputURL, outputURL: outputURL, intent: intent)
            return plan
        }

        let rasterImage = try decodeToRaster(inputURL: inputURL, format: intent.sourceFormat)
        let normalizedImage = try normalizeColorIfNeeded(rasterImage, intent: intent)
        try encodeRasterImage(normalizedImage, outputURL: outputURL, format: intent.targetFormat, intent: intent)
        return plan
    }

    private func convertToSVG(
        inputURL: URL,
        outputURL: URL,
        intent: ConversionIntent,
        plan: ConversionPlan
    ) throws -> ConversionPlan {
        if intent.sourceFormat == .webp || intent.sourceFormat == .avif {
            let rasterImage = try decodeToRaster(inputURL: inputURL, format: intent.sourceFormat)
            try svgService.convertRasterImageToSVG(rasterImage.cgImage, outputURL: outputURL, intent: intent)
            return plan
        }

        try svgService.convertToSVG(inputURL: inputURL, outputURL: outputURL, intent: intent)
        return plan
    }

    private func shouldPassthroughToPreserveMetadata(intent: ConversionIntent) -> Bool {
        intent.options.metadataPolicy == .preserve
            && intent.sourceFormat == intent.targetFormat
            && intent.options.animationPolicy == .preserveWhenSupported
            && intent.options.outputColorSpace == .sRGB
            && !intent.targetFormat.isVector
    }

    func copyInputToOutput(inputURL: URL, outputURL: URL) throws {
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        do {
            try FileManager.default.copyItem(at: inputURL, to: outputURL)
        } catch {
            throw ConversionEngineError.fileWriteFailed
        }
    }

    func encodeRasterImage(
        _ image: DecodedRasterImage,
        outputURL: URL,
        format: ImageFormat,
        intent: ConversionIntent
    ) throws {
        switch format {
        case .pdf:
            try encodePDF(image.cgImage, outputURL: outputURL)
        case .eps, .svg, .raw:
            throw ConversionEngineError.unsupportedFormat
        case .jpeg, .bmp, .heic, .webp, .gif, .tiff, .png, .avif, .hdr:
            try codecs.encodeRasterImage(
                image,
                to: outputURL,
                as: format,
                options: rasterEncodingOptions(intent: intent)
            )
        }
    }

    func rasterEncodingOptions(intent: ConversionIntent) -> RasterEncodingOptions {
        RasterEncodingOptions(
            metadataPolicy: intent.options.metadataPolicy,
            preserveICCProfile: intent.options.preserveICCProfile
        )
    }
}
