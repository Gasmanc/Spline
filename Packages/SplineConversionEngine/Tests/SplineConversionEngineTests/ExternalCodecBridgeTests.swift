import CoreGraphics
import Foundation
import XCTest
@testable import SplineConversionEngine
import SplineDomain

final class ExternalCodecBridgeTests: XCTestCase {
    func testWebPRoundTrip() throws {
        let codec = ImageIOCodecService()
        let inputImage = try makeImage(red: 80, green: 120, blue: 200)

        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let webpURL = tempDir.appendingPathComponent("sample.webp")

        try codec.encodeRasterImage(DecodedRasterImage(cgImage: inputImage), to: webpURL, as: .webp)
        let decoded = try codec.decodeRasterImage(at: webpURL, as: .webp)

        XCTAssertEqual(decoded.cgImage.width, inputImage.width)
        XCTAssertEqual(decoded.cgImage.height, inputImage.height)
    }

    func testAVIFRoundTrip() throws {
        let codec = ImageIOCodecService()
        let inputImage = try makeImage(red: 20, green: 160, blue: 90)

        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let avifURL = tempDir.appendingPathComponent("sample.avif")

        try codec.encodeRasterImage(DecodedRasterImage(cgImage: inputImage), to: avifURL, as: .avif)
        let decoded = try codec.decodeRasterImage(at: avifURL, as: .avif)

        XCTAssertEqual(decoded.cgImage.width, inputImage.width)
        XCTAssertEqual(decoded.cgImage.height, inputImage.height)
    }

    private func makeImage(red: UInt8, green: UInt8, blue: UInt8) throws -> CGImage {
        let width = 4
        let height = 4
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ConversionEngineError.encodeFailed
        }

        context.setFillColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        guard let image = context.makeImage() else {
            throw ConversionEngineError.encodeFailed
        }

        return image
    }
}
