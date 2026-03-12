import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import SplineVectorization
import SplineDomain

final class SVGConversionServiceTests: XCTestCase {
    func testConvertPNGToSVGCreatesOutputFile() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let inputURL = tempDir.appendingPathComponent("input.png")
        let outputURL = tempDir.appendingPathComponent("output.svg")

        let image = try makeImage(width: 3, height: 2)
        try writePNG(image: image, to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .svg,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        let service = SVGConversionService()
        try service.convertToSVG(inputURL: inputURL, outputURL: outputURL, intent: intent)

        let svgData = try Data(contentsOf: outputURL)
        guard let text = String(data: svgData, encoding: .utf8) else {
            XCTFail("Expected UTF8 SVG output")
            return
        }

        XCTAssertTrue(text.contains("<svg"))
        XCTAssertTrue(text.contains("</svg>"))
    }

    private func makeImage(width: Int, height: Int) throws -> CGImage {
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

        context.setFillColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        guard let image = context.makeImage() else {
            throw SVGTraceError.decodeFailed
        }

        return image
    }

    private func writePNG(image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw SVGTraceError.writeFailed
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw SVGTraceError.writeFailed
        }
    }
}
