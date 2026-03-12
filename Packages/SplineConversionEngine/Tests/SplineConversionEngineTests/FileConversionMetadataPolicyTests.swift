import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class FileConversionMetadataPolicyTests: XCTestCase, FileConversionTestSupport {
    func testMetadataStripByDefaultAcrossRasterTargets() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("in-with-meta.png")
        try writePNGWithMetadata(to: inputURL)

        let targets: [ImageFormat] = [.png, .jpeg, .tiff, .gif, .bmp]
        for target in targets {
            let outputURL = tempDir.appendingPathComponent("out-strip-\(target.rawValue).\(target.rawValue)")
            let intent = ConversionIntent(
                sourceFormat: .png,
                targetFormat: target,
                containsAlphaChannel: true,
                containsAnimation: false,
                options: ConversionOptions(outputColorSpace: .sRGB)
            )

            _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)
            XCTAssertFalse(try hasEXIFUserComment(at: outputURL), "Expected stripped metadata for \(target.rawValue)")
        }
    }

    func testMetadataPreservePolicySupportedForSameFormatPassthrough() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("in-with-meta.png")
        let outputURL = tempDir.appendingPathComponent("out-preserve.png")
        try writePNGWithMetadata(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .png,
            targetFormat: .png,
            containsAlphaChannel: true,
            containsAnimation: false,
            options: ConversionOptions(
                outputColorSpace: .sRGB,
                animationPolicy: .preserveWhenSupported,
                metadataPolicy: .preserve,
                preserveICCProfile: true
            )
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)

        XCTAssertTrue(try hasEXIFUserComment(at: outputURL))
    }
}
