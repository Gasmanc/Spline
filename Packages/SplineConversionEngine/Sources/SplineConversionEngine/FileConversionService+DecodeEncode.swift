import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import PDFKit
import SplineDomain

extension FileConversionService {
    func decodeToRaster(inputURL: URL, format: ImageFormat) throws -> DecodedRasterImage {
        switch format {
        case .pdf:
            return try DecodedRasterImage(cgImage: decodePDF(inputURL))
        case .raw:
            return try DecodedRasterImage(cgImage: decodeRAW(inputURL))
        case .eps:
            return try DecodedRasterImage(cgImage: decodeEPS(inputURL))
        case .svg:
            return try DecodedRasterImage(cgImage: svgService.rasterizeSVGDocument(inputURL: inputURL))
        case .jpeg, .bmp, .heic, .webp, .gif, .tiff, .png, .avif, .hdr:
            return try codecs.decodeRasterImage(at: inputURL, as: format)
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

    private func decodeEPS(_ inputURL: URL) throws -> CGImage {
        if let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil),
           let image = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            return image
        }

        if let ciImage = CIImage(contentsOf: inputURL) {
            let context = CIContext(options: [
                CIContextOption.priorityRequestLow: false,
                CIContextOption.outputPremultiplied: true
            ])
            if let image = context.createCGImage(ciImage, from: ciImage.extent) {
                return image
            }
        }

        #if os(macOS)
        if let fallback = try decodeEPSUsingSIPS(inputURL) {
            return fallback
        }
        #endif

        throw ConversionEngineError.decodeFailed
    }

    #if os(macOS)
    private func decodeEPSUsingSIPS(_ inputURL: URL) throws -> CGImage? {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("spline-eps-fallback", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let outputURL = tempDirectory.appendingPathComponent("\(UUID().uuidString).png")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
        process.arguments = ["-s", "format", "png", inputURL.path, "--out", outputURL.path]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0 else {
            return nil
        }

        defer {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                _ = error
            }
        }

        guard let source = CGImageSourceCreateWithURL(outputURL as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return image
    }
    #endif

    func encodePDF(_ image: CGImage, outputURL: URL) throws {
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
