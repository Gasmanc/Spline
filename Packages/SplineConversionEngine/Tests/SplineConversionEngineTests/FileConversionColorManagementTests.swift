import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class FileConversionColorManagementTests: XCTestCase, FileConversionTestSupport {
    func testColorSpaceCMYKWhenTargetSupportsCMYK() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("in.png")
        let outputURL = tempDir.appendingPathComponent("out-cmyk.tiff")

        try writePNG(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .tiff,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .cmyk)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)

        let colorModel = try colorModel(at: outputURL)
        XCTAssertEqual(colorModel, "CMYK")
    }

    func testColorSpaceCMYKFallsBackToRGBWhenTargetCannotEncodeCMYK() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("in.png")
        let outputURL = tempDir.appendingPathComponent("out-cmyk-requested.png")

        try writePNG(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .png,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(outputColorSpace: .cmyk)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)

        let colorModel = try colorModel(at: outputURL)
        XCTAssertEqual(colorModel, "RGB")
    }
}
