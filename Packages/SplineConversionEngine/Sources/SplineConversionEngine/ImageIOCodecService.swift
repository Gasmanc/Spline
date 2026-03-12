import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import SplineDomain

public struct DecodedRasterImage: Sendable {
    public let cgImage: CGImage

    public init(cgImage: CGImage) {
        self.cgImage = cgImage
    }
}

public struct ImageIOCodecService: Sendable {
    private static let destinationTypeMap: [ImageFormat: String] = [
        .jpeg: UTType.jpeg.identifier,
        .bmp: UTType.bmp.identifier,
        .heic: UTType.heic.identifier,
        .gif: UTType.gif.identifier,
        .tiff: UTType.tiff.identifier,
        .png: UTType.png.identifier
    ]

    public init() {}

    public func decodeRasterImage(at inputURL: URL, as format: ImageFormat) throws -> DecodedRasterImage {
        guard !format.isVector else {
            throw ConversionEngineError.unsupportedFormat
        }

        if format == .webp {
            let data = try Data(contentsOf: inputURL)
            return try ExternalCodecBridge.decodeWebP(data: data)
        }

        if format == .avif {
            let data = try Data(contentsOf: inputURL)
            return try ExternalCodecBridge.decodeAVIF(data: data)
        }

        guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
            throw ConversionEngineError.fileReadFailed
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ConversionEngineError.decodeFailed
        }

        return DecodedRasterImage(cgImage: image)
    }

    public func encodeRasterImage(_ image: DecodedRasterImage, to outputURL: URL, as format: ImageFormat) throws {
        if format == .webp {
            let encoded = try ExternalCodecBridge.encodeWebP(image: image)
            try encoded.write(to: outputURL, options: .atomic)
            return
        }

        if format == .avif {
            let encoded = try ExternalCodecBridge.encodeAVIF(image: image)
            try encoded.write(to: outputURL, options: .atomic)
            return
        }

        guard let destinationType = Self.destinationTypeMap[format] else {
            throw ConversionEngineError.unsupportedFormat
        }

        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            destinationType as CFString,
            1,
            nil
        ) else {
            throw ConversionEngineError.fileWriteFailed
        }

        CGImageDestinationAddImage(destination, image.cgImage, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw ConversionEngineError.encodeFailed
        }
    }
}
