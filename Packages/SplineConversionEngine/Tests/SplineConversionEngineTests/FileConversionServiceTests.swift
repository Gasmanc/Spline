import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class FileConversionServiceTests: XCTestCase {
    func testConvertPNGToSVG() throws {
        let service = FileConversionService()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let inputURL = tempDir.appendingPathComponent("in.png")
        let outputURL = tempDir.appendingPathComponent("out.svg")

        try writePNG(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .svg,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
    }

    func testConvertEPSUsesDedicatedDecodePath() throws {
        let service = FileConversionService()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let inputURL = tempDir.appendingPathComponent("in.eps")
        let outputURL = tempDir.appendingPathComponent("out.png")
        try Data("%!PS-Adobe-3.0 EPSF-3.0\n%%BoundingBox: 0 0 10 10\nshowpage\n".utf8).write(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .eps,
            targetFormat: .png,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        XCTAssertThrowsError(try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)) { error in
            XCTAssertNotEqual(error as? ConversionEngineError, .unsupportedFormat)
        }
    }

    func testConvertPNGToPDF() throws {
        let service = FileConversionService()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let inputURL = tempDir.appendingPathComponent("in.png")
        let outputURL = tempDir.appendingPathComponent("out.pdf")
        try writePNG(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .pdf,
            containsAlphaChannel: false,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
    }

    private func writePNG(to url: URL) throws {
        guard let context = CGContext(
            data: nil,
            width: 8,
            height: 8,
            bitsPerComponent: 8,
            bytesPerRow: 8 * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ConversionEngineError.encodeFailed
        }

        context.setFillColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))

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
