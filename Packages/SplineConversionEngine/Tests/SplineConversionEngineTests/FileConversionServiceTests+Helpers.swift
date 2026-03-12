import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import SplineConversionEngine

protocol FileConversionTestSupport: XCTestCase {}

extension FileConversionTestSupport {
    func makeTempDirectory(file: StaticString = #filePath, line: UInt = #line) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        } catch {
            XCTFail("Failed to create temp directory: \(error)", file: file, line: line)
        }

        return tempDirectory
    }

    func frameCount(at url: URL) throws -> Int {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw ConversionEngineError.fileReadFailed
        }
        return CGImageSourceGetCount(source)
    }

    func colorModel(at url: URL) throws -> String {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let model = properties[kCGImagePropertyColorModel] as? String else {
            throw ConversionEngineError.decodeFailed
        }

        return model
    }

    func hasEXIFUserComment(at url: URL) throws -> Bool {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any] else {
            return false
        }

        return exif[kCGImagePropertyExifUserComment] != nil
    }

    func writeAnimatedGIF(to url: URL) throws {
        let red = try makeSolidImage(width: 8, height: 8, red: 1, green: 0, blue: 0)
        let blue = try makeSolidImage(width: 8, height: 8, red: 0, green: 0, blue: 1)

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.gif.identifier as CFString,
            2,
            nil
        ) else {
            throw ConversionEngineError.fileWriteFailed
        }

        let destinationProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
        ]
        CGImageDestinationSetProperties(destination, destinationProperties as CFDictionary)

        let frameProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 0.08]
        ]

        CGImageDestinationAddImage(destination, red, frameProperties as CFDictionary)
        CGImageDestinationAddImage(destination, blue, frameProperties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionEngineError.fileWriteFailed
        }
    }

    func writePNG(to url: URL) throws {
        let image = try makeSolidImage(width: 8, height: 8, red: 0.5, green: 0.3, blue: 0.7)

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

    func writePNGWithMetadata(to url: URL) throws {
        let image = try makeSolidImage(width: 8, height: 8, red: 0.2, green: 0.6, blue: 0.4)

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw ConversionEngineError.fileWriteFailed
        }

        let properties: [CFString: Any] = [
            kCGImagePropertyExifDictionary: [
                kCGImagePropertyExifUserComment: "spline-metadata-test"
            ]
        ]

        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw ConversionEngineError.fileWriteFailed
        }
    }

    func makeSolidImage(width: Int, height: Int, red: CGFloat, green: CGFloat, blue: CGFloat) throws -> CGImage {
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

        context.setFillColor(red: red, green: green, blue: blue, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        guard let image = context.makeImage() else {
            throw ConversionEngineError.encodeFailed
        }

        return image
    }
}
