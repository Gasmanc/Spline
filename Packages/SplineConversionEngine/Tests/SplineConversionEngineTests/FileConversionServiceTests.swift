import Foundation
import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class FileConversionServiceTests: XCTestCase, FileConversionTestSupport {
    func testConvertPNGToSVG() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()

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
        let tempDir = makeTempDirectory()

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

    func testConvertSVGToPNG() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()

        let inputURL = tempDir.appendingPathComponent("in.svg")
        let outputURL = tempDir.appendingPathComponent("out.png")
        let svg = """
        <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\">
          <rect x=\"0\" y=\"0\" width=\"16\" height=\"16\" fill=\"#FF0000\"/>
        </svg>
        """
        try Data(svg.utf8).write(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .svg,
            targetFormat: .png,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .sRGB)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
    }

    func testConvertPNGToPDF() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()

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
}
