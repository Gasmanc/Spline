import CoreGraphics
import Foundation
import ImageIO
import PDFKit
import SplineDomain

public struct SVGConversionService: Sendable {
    private let tracer: RasterSVGTracer

    public init(tracer: RasterSVGTracer = RasterSVGTracer()) {
        self.tracer = tracer
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

        let rasterImage = try decodeImage(inputURL: inputURL, format: intent.sourceFormat)
        let svg = try tracer.trace(image: rasterImage, mode: intent.options.traceMode, controls: intent.options.traceControls)

        guard let outputData = svg.data(using: .utf8) else {
            throw SVGTraceError.writeFailed
        }

        do {
            try outputData.write(to: outputURL, options: .atomic)
        } catch {
            throw SVGTraceError.writeFailed
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
