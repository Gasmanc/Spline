import CoreGraphics
import Foundation
import ImageIO
import PDFKit
import UniformTypeIdentifiers
import SplineDomain

public struct SVGConversionService: Sendable {
    private let tracer: RasterSVGTracer
    private let externalTracer: ExternalVTracerService

    public init(
        tracer: RasterSVGTracer = RasterSVGTracer(),
        externalTracer: ExternalVTracerService = ExternalVTracerService()
    ) {
        self.tracer = tracer
        self.externalTracer = externalTracer
    }

    public func convertToSVG(inputURL: URL, outputURL: URL, intent: ConversionIntent) throws {
        if intent.sourceFormat == .svg && intent.options.svgMode == .preserveVectorWhenPossible {
            let sourceData = try Data(contentsOf: inputURL)
            guard !sourceData.isEmpty else {
                throw SVGTraceError.readFailed
            }
            do {
                try sourceData.write(to: outputURL, options: .atomic)
                return
            } catch {
                throw SVGTraceError.writeFailed
            }
        }

        if shouldUseExternalTracer(for: intent.sourceFormat) {
            let traced = externalTracer.trace(
                inputURL: inputURL,
                outputURL: outputURL,
                mode: intent.options.traceMode,
                controls: intent.options.traceControls
            )
            if traced {
                return
            }
        }

        let rasterImage = try decodeImage(inputURL: inputURL, format: intent.sourceFormat)
        try convertRasterImageToSVG(rasterImage, outputURL: outputURL, intent: intent)
    }

    public func convertRasterImageToSVG(_ image: CGImage, outputURL: URL, intent: ConversionIntent) throws {
        let svg = try tracer.trace(image: image, mode: intent.options.traceMode, controls: intent.options.traceControls)

        guard let outputData = svg.data(using: .utf8) else {
            throw SVGTraceError.writeFailed
        }

        do {
            try outputData.write(to: outputURL, options: .atomic)
        } catch {
            throw SVGTraceError.writeFailed
        }
    }

    private func shouldUseExternalTracer(for format: ImageFormat) -> Bool {
        switch format {
        case .jpeg, .bmp, .gif, .tiff, .png:
            return true
        case .heic, .webp, .raw, .svg, .avif, .hdr, .eps, .pdf:
            return false
        }
    }

    private func decodeImage(inputURL: URL, format: ImageFormat) throws -> CGImage {
        switch format {
        case .pdf:
            return try decodePDF(inputURL)
        case .eps:
            throw SVGTraceError.unsupportedInput
        case .svg:
            throw SVGTraceError.unsupportedInput
        default:
            return try decodeRaster(inputURL)
        }
    }

    private func decodeRaster(_ inputURL: URL) throws -> CGImage {
        guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw SVGTraceError.decodeFailed
        }
        return image
    }

    private func decodePDF(_ inputURL: URL) throws -> CGImage {
        guard let document = PDFDocument(url: inputURL),
              let page = document.page(at: 0) else {
            throw SVGTraceError.decodeFailed
        }

        let pageBounds = page.bounds(for: .mediaBox)
        let width = max(Int(pageBounds.width.rounded(.up)), 1)
        let height = max(Int(pageBounds.height.rounded(.up)), 1)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw SVGTraceError.decodeFailed
        }

        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.saveGState()
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()

        guard let image = context.makeImage() else {
            throw SVGTraceError.decodeFailed
        }

        return image
    }
}
