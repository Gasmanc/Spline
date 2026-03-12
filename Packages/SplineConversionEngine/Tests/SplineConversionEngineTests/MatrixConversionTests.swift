import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class MatrixConversionTests: XCTestCase {
    func testWebPToPNGAndAVIFToPDFConversions() throws {
        let service = FileConversionService()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let pngInput = tempDir.appendingPathComponent("input.png")
        try writePNG(to: pngInput)

        let webp = tempDir.appendingPathComponent("sample.webp")
        let avif = tempDir.appendingPathComponent("sample.avif")
        let outPNG = tempDir.appendingPathComponent("fromwebp.png")
        let outPDF = tempDir.appendingPathComponent("fromavif.pdf")

        let pngToWebP = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .webp,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )
        _ = try service.convert(inputURL: pngInput, outputURL: webp, intent: pngToWebP)

        let pngToAVIF = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .avif,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )
        _ = try service.convert(inputURL: pngInput, outputURL: avif, intent: pngToAVIF)

        let webpToPNG = ConversionIntent(
            sourceFormat: .webp,
            targetFormat: .png,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )
        _ = try service.convert(inputURL: webp, outputURL: outPNG, intent: webpToPNG)

        let avifToPDF = ConversionIntent(
            sourceFormat: .avif,
            targetFormat: .pdf,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )
        _ = try service.convert(inputURL: avif, outputURL: outPDF, intent: avifToPDF)

        XCTAssertTrue(FileManager.default.fileExists(atPath: outPNG.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: outPDF.path))
    }

    private func writePNG(to url: URL) throws {
        guard let context = CGContext(
            data: nil,
            width: 10,
            height: 10,
            bitsPerComponent: 8,
            bytesPerRow: 40,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ConversionEngineError.encodeFailed
        }

        context.setFillColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))

        guard let image = context.makeImage() else {
            throw ConversionEngineError.encodeFailed
        }

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw ConversionEngineError.fileWriteFailed
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ConversionEngineError.fileWriteFailed
        }
    }
}
