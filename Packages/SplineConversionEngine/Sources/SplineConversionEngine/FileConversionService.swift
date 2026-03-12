import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import PDFKit
import SplineDomain
import SplineVectorization

public struct FileConversionService: Sendable {
    private let planner: ConversionGraphPlanner
    private let codecs: ImageIOCodecService
    private let svgService: SVGConversionService

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

        if intent.targetFormat == .svg {
            return try convertToSVG(inputURL: inputURL, outputURL: outputURL, intent: intent, plan: plan)
        }

        let rasterImage = try decodeToRaster(inputURL: inputURL, format: intent.sourceFormat)
        try encodeRasterImage(rasterImage, outputURL: outputURL, format: intent.targetFormat)
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

    private func decodeToRaster(inputURL: URL, format: ImageFormat) throws -> DecodedRasterImage {
        switch format {
        case .pdf:
            return try DecodedRasterImage(cgImage: decodePDF(inputURL))
        case .raw:
            return try DecodedRasterImage(cgImage: decodeRAW(inputURL))
        case .eps:
            throw ConversionEngineError.unsupportedFormat
        case .svg:
            throw ConversionEngineError.unsupportedFormat
        case .jpeg, .bmp, .heic, .webp, .gif, .tiff, .png, .avif, .hdr:
            return try codecs.decodeRasterImage(at: inputURL, as: format)
        }
    }

    private func encodeRasterImage(_ image: DecodedRasterImage, outputURL: URL, format: ImageFormat) throws {
        switch format {
        case .pdf:
            try encodePDF(image.cgImage, outputURL: outputURL)
        case .eps, .svg:
            throw ConversionEngineError.unsupportedFormat
        case .raw:
            throw ConversionEngineError.unsupportedFormat
        case .jpeg, .bmp, .heic, .webp, .gif, .tiff, .png, .avif, .hdr:
            try codecs.encodeRasterImage(image, to: outputURL, as: format)
        }
    }

    private func decodePDF(_ inputURL: URL) throws -> CGImage {
        guard let document = PDFDocument(url: inputURL),
              let page = document.page(at: 0) else {
            throw ConversionEngineError.decodeFailed
        }

        let bounds = page.bounds(for: .mediaBox)
        let width = max(Int(bounds.width.rounded(.up)), 1)
        let height = max(Int(bounds.height.rounded(.up)), 1)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ConversionEngineError.decodeFailed
        }

        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.saveGState()
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()

        guard let image = context.makeImage() else {
            throw ConversionEngineError.decodeFailed
        }

        return image
    }

    private func decodeRAW(_ inputURL: URL) throws -> CGImage {
        guard let ciImage = CIImage(contentsOf: inputURL) else {
            throw ConversionEngineError.decodeFailed
        }

        let context = CIContext(options: [
            CIContextOption.priorityRequestLow: false,
            CIContextOption.outputPremultiplied: true
        ])

        guard let image = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw ConversionEngineError.decodeFailed
        }

        return image
    }

    private func encodePDF(_ image: CGImage, outputURL: URL) throws {
        var mediaBox = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        guard let context = CGContext(outputURL as CFURL, mediaBox: &mediaBox, nil) else {
            throw ConversionEngineError.fileWriteFailed
        }

        context.beginPDFPage(nil)
        context.draw(image, in: mediaBox)
        context.endPDFPage()
        context.closePDF()
    }
}
