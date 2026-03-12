import Foundation
import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class FileConversionAnimationPolicyTests: XCTestCase, FileConversionTestSupport {
    func testAnimationPolicyPreserveKeepsAnimatedGIFFrames() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("animated-in.gif")
        let outputURL = tempDir.appendingPathComponent("animated-out.gif")

        try writeAnimatedGIF(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .gif,
            targetFormat: .gif,
            containsAlphaChannel: true,
            containsAnimation: true,
            options: ConversionOptions(outputColorSpace: .sRGB, animationPolicy: .preserveWhenSupported)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)
        XCTAssertEqual(try frameCount(at: outputURL), 2)
    }

    func testAnimationPolicyFirstFrameWritesSingleRasterOutput() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("animated-in.gif")
        let outputURL = tempDir.appendingPathComponent("first-frame.png")

        try writeAnimatedGIF(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .gif,
            targetFormat: .png,
            containsAlphaChannel: true,
            containsAnimation: true,
            options: ConversionOptions(outputColorSpace: .sRGB, animationPolicy: .firstFrameOnly)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
        XCTAssertEqual(try frameCount(at: outputURL), 1)
    }

    func testAnimationPolicySplitWritesFrameSequenceAndManifest() throws {
        let service = FileConversionService()
        let tempDir = makeTempDirectory()
        let inputURL = tempDir.appendingPathComponent("animated-in.gif")
        let outputURL = tempDir.appendingPathComponent("split.png")

        try writeAnimatedGIF(to: inputURL)

        let intent = ConversionIntent(
            sourceFormat: .gif,
            targetFormat: .png,
            containsAlphaChannel: true,
            containsAnimation: true,
            options: ConversionOptions(outputColorSpace: .sRGB, animationPolicy: .splitToFrames)
        )

        _ = try service.convert(inputURL: inputURL, outputURL: outputURL, intent: intent)

        XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("split-frame-0001.png").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("split-frame-0002.png").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("split-frames.json").path))
    }
}
